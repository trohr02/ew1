-- Auto Generated (Do not modify) 1D26278DC1B5E31B0F12F0A6BCC55C91C2994905FD0ADC042F037689B0165CA7
CREATE   VIEW gold.invoice_summary_report AS
SELECT
    c.CustomerCategory,
    b.InvoiceDate,
    sum(InvoicedAmount) as InvoicedAmount,
    sum(PaymentAmount + CreditNoteAmount + RefundAmount) as SettledAmount,
    sum(RemainingAmount) as Remaining,
    sum(PaymentAmount) as PaidAmount, 
    sum(InvoicedAmount - PaymentAmount) as UnpaidAmount,
--    sum(PaymentAmount + CreditNoteAmount + RefundAmount)  / nullif(sum(InvoicedAmount),0) as SettledPct,
--    sum(RemainingAmount) / nullif(sum(InvoicedAmount),0) as RemainingPct,
--    sum(InvoicedAmount) - sum(PaymentAmount + CreditNoteAmount + RefundAmount) - sum(RemainingAmount) as TieCheck
    count(*) as InvoiceCount,
    sum(case when RemainingAmount = 0 then 1 else 0 end) as SettledInvoiceCount,
    sum(case when RemainingAmount > 0 then 1 else 0 end) as UnsettledInvoiceCount,
    sum(case when InvoicedAmount = PaymentAmount then 1 else 0 end) as PaidInvoiceCount,
    sum(case when InvoicedAmount > PaymentAmount then 1 else 0 end) as UnpaidInvoiceCount   
FROM gold.invoice_balance_fact b
JOIN gold.customer c
  on c.CustomerId = b.CustomerId
GROUP BY c.CustomerCategory, b.InvoiceDate
;