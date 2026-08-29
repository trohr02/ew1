/* 
============================================================
Procedure : bronze.sp_refresh
Target:     gold layer
============================================================
Refresh data in gold layer - tuncate & insert
============================================================
*/
CREATE   PROCEDURE gold.sp_refresh AS
BEGIN

TRUNCATE TABLE gold.transaction_fact;
TRUNCATE TABLE gold.invoice_balance_fact;
TRUNCATE TABLE gold.customer;


INSERT INTO gold.customer
(CustomerId, CustomerName, CustomerCategory)
SELECT 
	CustomerId, 
	CustomerName,
	CustomerCategory
FROM silver.customer
WHERE DeletedFlag = 0
;



INSERT INTO gold.transaction_fact
(CompanyId, InvoiceKey, DocumentKey, CustomerId, CountryId, PostingDate, InvoiceDate,
TransactionType, SignedAmount, Amount, SourceAmount)
SELECT
	u.CompanyId,
	u.InvoiceKey,
	u.DocumentKey,
	u.CustomerId,
	u.CountryId,
	u.PostingDate,
	MAX(u.InvoiceDate) over (partition by u.InvoiceKey) as InvoiceDate,
	u.TransactionType,
	u.SignedAmount,
	u.Amount,
	u.SourceAmount
FROM (
	SELECT
		i.CompanyId,
		i.CompanyId + '|' + i.InvoiceNumber   AS InvoiceKey,
		i.CompanyId + '|' + i.InvoiceNumber   AS DocumentKey,
		i.CustomerId                          AS CustomerId,
		i.CountryId                           AS CountryId,
		i.PostingDate                         AS InvoiceDate,
		i.PostingDate                         AS PostingDate,
		'Invoice'                             AS TransactionType,
		ABS(ISNULL(i.Amount, 0))              AS SignedAmount,
		ABS(ISNULL(i.Amount, 0))              AS Amount,
		ISNULL(i.Amount, 0)                   AS SourceAmount
	FROM silver.invoice i
    WHERE i.DeletedFlag = 0
	UNION ALL
	SELECT
		p.CompanyId,
		p.CompanyId + '|' + p.InvoiceNumber   AS InvoiceKey,
		p.CompanyId + '|' + p.PaymentNumber   AS DocumentKey,
		p.CustomerId,
		p.CountryId,
		NULL                                  AS InvoiceDate,
		p.PostingDate,
		p.PaymentType                         AS TransactionType,
		CASE p.PaymentType
			WHEN 'Payment'             THEN -ABS(ISNULL(p.Amount, 0))
			WHEN 'CR/Adj Note'         THEN -ABS(ISNULL(p.Amount, 0))
			WHEN 'Refund'              THEN -ABS(ISNULL(p.Amount, 0))
			WHEN 'Finance Charge Memo' THEN  ABS(ISNULL(p.Amount, 0))
			WHEN 'Blank'               THEN -ABS(ISNULL(p.Amount, 0))                   
		END                                   AS SignedAmount,
		ABS(ISNULL(p.Amount, 0))              AS Amount,
		ISNULL(p.Amount, 0)                   AS SourceAmount
	FROM silver.payment p
	-- In payment, there are some references to invoices which does not exist in invoice table
	INNER JOIN silver.invoice i2
	  on i2.CompanyId = p.CompanyId
	  and i2.InvoiceNumber = p.InvoiceNumber
      and i2.DeletedFlag = 0
	WHERE p.DeletedFlag = 0
) u
;



INSERT INTO gold.invoice_balance_fact 
(InvoiceKey, CustomerId, CountryId, InvoiceDate, 
InvoicedAmount, PaymentAmount, CreditNoteAmount, RefundAmount, FinanceChargeAmount, RemainingAmount)
SELECT
    InvoiceKey,
    MAX(CustomerId)  AS CustomerId,
    MAX(CountryId)   AS CountryId,
    MAX(InvoiceDate) AS InvoiceDate,
    SUM(CASE 
		WHEN TransactionType = 'Invoice'
        THEN Amount ELSE 0  END
	) AS InvoicedAmount,
    SUM(CASE
		WHEN TransactionType = 'Payment' 
		  or TransactionType = 'Blank'
        THEN Amount ELSE 0 END
	) AS PaymentAmount,
    SUM(CASE 
	    WHEN TransactionType = 'CR/Adj Note'
        THEN Amount ELSE 0 END
	) AS CreditNoteAmount,
    SUM(CASE 
	    WHEN TransactionType = 'Refund'
        THEN Amount ELSE 0 END
	) AS RefundAmount,
    SUM(CASE 
	    WHEN TransactionType = 'Finance Charge Memo'
        THEN Amount ELSE 0 END
	) AS FinanceChargeAmount,
    SUM(SignedAmount) AS RemainingAmount
FROM gold.transaction_fact
GROUP BY InvoiceKey;

END