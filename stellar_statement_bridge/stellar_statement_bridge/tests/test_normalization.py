import unittest
from decimal import Decimal

from stellar_statement_bridge.stellar_statement_bridge.sdp.normalization import (
    PaymentShapeError,
    normalize_page,
    normalize_payment,
)


def payment(**overrides):
    value = {
        "id": "payment-1",
        "status": "SUCCESS",
        "type": "DISBURSEMENT",
        "amount": "12.3400000",
        "stellar_transaction_id": "stellar-tx-1",
        "asset": {"code": "USDC", "issuer": "GISSUER"},
        "source_wallet": "wallet-1",
        "external_payment_id": "invoice-1",
    }
    value.update(overrides)
    return value


class NormalizePaymentTests(unittest.TestCase):
    def test_successful_stellar_payment_is_eligible_and_decimal_exact(self):
        result = normalize_payment(payment())
        self.assertTrue(result.eligible)
        self.assertEqual(result.amount, Decimal("12.3400000"))
        self.assertEqual(result.stellar_transaction_id, "stellar-tx-1")

    def test_nullable_native_asset_issuer_is_allowed_for_later_exact_mapping(self):
        result = normalize_payment(payment(asset={"code": "XLM", "issuer": None}))
        self.assertTrue(result.eligible)
        self.assertIsNone(result.asset_issuer)

    def test_rejects_non_success_missing_transaction_and_unsupported_type(self):
        result = normalize_payment(payment(status="PENDING", type="OTHER", stellar_transaction_id=None))
        self.assertFalse(result.eligible)
        self.assertEqual(
            result.blocked_reasons,
            ("status_not_success", "unsupported_payment_type", "missing_stellar_transaction_id"),
        )

    def test_missing_payment_id_is_blocked_not_discarded(self):
        result = normalize_payment(payment(id=None))
        self.assertIn("missing_payment_id", result.blocked_reasons)

    def test_amount_must_be_a_positive_finite_decimal_string(self):
        for value, reason in ((12, "invalid_amount"), (12.5, "invalid_amount"), ("NaN", "invalid_amount"), ("0", "amount_not_positive"), ("-1", "amount_not_positive")):
            with self.subTest(value=value):
                self.assertIn(reason, normalize_payment(payment(amount=value)).blocked_reasons)

    def test_unknown_recipient_fields_are_never_retained(self):
        result = normalize_payment(payment(recipient={"email": "private@example.invalid"}, unknown="secret"))
        self.assertFalse(hasattr(result, "recipient"))
        self.assertFalse(hasattr(result, "unknown"))

    def test_page_requires_data_array_and_object_records(self):
        with self.assertRaises(PaymentShapeError):
            normalize_page({"pagination": {}})
        with self.assertRaises(PaymentShapeError):
            normalize_page({"data": ["not-an-object"]})

    def test_page_normalizes_records(self):
        self.assertEqual(len(normalize_page({"data": [payment()]})), 1)


if __name__ == "__main__":
    unittest.main()
