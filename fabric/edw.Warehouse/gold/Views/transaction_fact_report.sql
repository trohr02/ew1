-- Auto Generated (Do not modify) C15DDEB4752C3E133A6EC26E2B8D794D22A03947E08123651CDB139365EF3FA5
CREATE   VIEW gold.transaction_fact_report as
SELECT
c.CustomerName,
c.CustomerCategory,
f.*,
CASE 
	WHEN TransactionType = 'Invoice'
	THEN Amount ELSE 0 
END AS InvoicedAmount,
CASE
	WHEN TransactionType = 'Payment' 
	  or TransactionType = 'Blank'
	THEN Amount ELSE 0
END AS PaymentAmount,
CASE 
	WHEN TransactionType = 'CR/Adj Note'
	THEN Amount ELSE 0 
END AS CreditNoteAmount,
CASE 
	WHEN TransactionType = 'Refund'
	THEN Amount ELSE 0
END AS RefundAmount,
CASE 
	WHEN TransactionType = 'Finance Charge Memo'
	THEN Amount ELSE 0 
END AS FinanceChargeAmount
FROM gold.transaction_fact f
LEFT OUTER JOIN gold.customer c
  ON f.CustomerId = c.CustomerId
;