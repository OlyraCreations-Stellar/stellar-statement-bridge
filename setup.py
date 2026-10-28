from setuptools import find_packages, setup


setup(
    name="stellar_statement_bridge",
    version="0.1.0",
    description="Read-only Stellar Disbursement Platform evidence for ERPNext reconciliation",
    author="OlyraCreations-Stellar",
    license="Apache-2.0",
    packages=find_packages(),
    python_requires=">=3.14,<3.15",
    zip_safe=False,
    include_package_data=True,
)
