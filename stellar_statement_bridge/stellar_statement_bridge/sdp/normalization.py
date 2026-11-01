"""Pure, privacy-preserving normalization for SDP payment response objects."""

from dataclasses import dataclass
from decimal import Decimal, InvalidOperation
from typing import Any, Mapping


SUPPORTED_TYPES = frozenset({"DIRECT", "DISBURSEMENT"})
IMPORTABLE_STATUS = "SUCCESS"


class PaymentShapeError(ValueError):
    """Raised when an SDP response cannot safely be interpreted as a payment page."""


@dataclass(frozen=True, slots=True)
class NormalizedPayment:
    """Allowlisted payment evidence; the original payload and recipient data are discarded."""

    payment_id: str | None
    status: str | None
    payment_type: str | None
    amount: Decimal | None
    stellar_transaction_id: str | None
    asset_code: str | None
    asset_issuer: str | None
    source_wallet_id: str | None
    external_payment_id: str | None
    blocked_reasons: tuple[str, ...]

    @property
    def eligible(self) -> bool:
        return not self.blocked_reasons


def _optional_text(value: Any) -> str | None:
    if value is None or not isinstance(value, str):
        return None
    normalized = value.strip()
    return normalized or None


def normalize_payment(payload: Mapping[str, Any]) -> NormalizedPayment:
    """Normalize one payment. Unknown fields are ignored and never retained."""
    if not isinstance(payload, Mapping):
        raise PaymentShapeError("payment record must be an object")

    payment_id = _optional_text(payload.get("id"))
    status = _optional_text(payload.get("status"))
    payment_type = _optional_text(payload.get("type"))
    transaction_id = _optional_text(payload.get("stellar_transaction_id"))
    source_wallet_id = _optional_text(payload.get("source_wallet"))
    external_payment_id = _optional_text(payload.get("external_payment_id"))

    asset = payload.get("asset")
    if asset is not None and not isinstance(asset, Mapping):
        asset = None
    asset_code = _optional_text(asset.get("code")) if asset else None
    asset_issuer = _optional_text(asset.get("issuer")) if asset else None

    amount: Decimal | None = None
    amount_value = payload.get("amount")
    if isinstance(amount_value, str):
        try:
            parsed_amount = Decimal(amount_value)
            if parsed_amount.is_finite():
                amount = parsed_amount
        except InvalidOperation:
            pass

    reasons: list[str] = []
    if payment_id is None:
        reasons.append("missing_payment_id")
    if status != IMPORTABLE_STATUS:
        reasons.append("status_not_success")
    if payment_type not in SUPPORTED_TYPES:
        reasons.append("unsupported_payment_type")
    if transaction_id is None:
        reasons.append("missing_stellar_transaction_id")
    if amount is None:
        reasons.append("invalid_amount")
    elif amount <= 0:
        reasons.append("amount_not_positive")
    if asset_code is None:
        reasons.append("missing_asset_code")

    return NormalizedPayment(
        payment_id=payment_id,
        status=status,
        payment_type=payment_type,
        amount=amount,
        stellar_transaction_id=transaction_id,
        asset_code=asset_code,
        asset_issuer=asset_issuer,
        source_wallet_id=source_wallet_id,
        external_payment_id=external_payment_id,
        blocked_reasons=tuple(reasons),
    )


def normalize_page(payload: Mapping[str, Any]) -> tuple[NormalizedPayment, ...]:
    """Validate and normalize the documented SDP `{data: [...]}` page envelope."""
    if not isinstance(payload, Mapping) or not isinstance(payload.get("data"), list):
        raise PaymentShapeError("payment page must contain a data array")
    return tuple(normalize_payment(item) for item in payload["data"])
