-- Auto Generated (Do not modify) 8AD42A76E4E2344649EAEF622050D6559DB98D310F29FC4A040C5735A2BF3178
-- Report - Splatnost faktur - za kolik dnů of InvoiceDate byla faktura splacena
CREATE   VIEW gold.invoice_payment_status_report AS
SELECT 
  CompanyId,
  InvoiceKey,
  CustomerId,
  CustomerName,
  CustomerCategory,
  MAX(InvoiceDate) as InvoiceDate,
  MAX(FullyPaidDate) AS FullyPaidDate,
  MAX(DaysToPayment) AS DaysToPayment,
  MAX(Invoiced) as InvoicedAmount,
  MAX(InvoiceBalance) as UnpaidAmount,
  MAX(PaidCnt) as PaidCnt,
  MAX(UnpaidCnt) as UnpaidCnt
FROM (
  SELECT 
    CompanyId,
    InvoiceKey,
    CustomerId,
    CustomerName,
    CustomerCategory,
    InvoiceDate,
    Invoiced,
    InvoiceBalance,
      TransactionType,
      PostingDate,
      SignedAmount,
      RunningPayment,
    CASE WHEN InvoiceBalance = 0 THEN 1 ELSE 0 END AS PaidCnt,
    CASE WHEN InvoiceBalance > 0 THEN 1 ELSE 0 END AS UnpaidCnt,
    case WHEN InvoiceBalance = 0 THEN DaysToPayment else null END AS DaysToPayment,
    case WHEN InvoiceBalance = 0 THEN FullyPaidDate else null END AS FullyPaidDate
    FROM (
    SELECT
      b.CompanyId,
      b.InvoiceKey,
      c.CustomerId,
      c.CustomerName,
      c.CustomerCategory,
      --count(*) over (partition by InvoiceKey) as TransactionCount,
      InvoiceDate,
      PostingDate,
      SignedAmount,
      TransactionType,
      DATEDIFF(day, InvoiceDate, PostingDate) AS DayCount,
      MAX(CASE WHEN TransactionType in ('Invoice') then SignedAmount ELSE 0 END) OVER
        (PARTITION BY InvoiceKey) AS Invoiced,
      SUM(CASE WHEN TransactionType in ('Invoice','Payment') then SignedAmount ELSE 0 END) OVER 
        (PARTITION BY InvoiceKey ORDER BY PostingDate) AS RunningPayment,
      SUM(CASE WHEN TransactionType in ('Invoice','Payment') then SignedAmount ELSE 0 END) OVER 
        (PARTITION BY InvoiceKey) AS InvoiceBalance,
      MAX(CASE WHEN TransactionType in ('Invoice','Payment') then PostingDate ELSE CAST('2999-01-01' AS DATE) END) OVER 
        (PARTITION BY InvoiceKey) AS FullyPaidDate,
      MAX(CASE WHEN TransactionType in ('Invoice','Payment') then DATEDIFF(day, InvoiceDate, PostingDate)  ELSE 0 END) OVER 
        (PARTITION BY InvoiceKey) AS DaysToPayment
    FROM gold.transaction_fact b
    JOIN gold.customer c
      on c.CustomerId = b.CustomerId  
  -- WHERE InvoiceKey = '101|INV-SK-109500789'
  ) s
) d
GROUP BY 
  CompanyId,
  InvoiceKey,
  CustomerId,
  CustomerName,
  CustomerCategory
;