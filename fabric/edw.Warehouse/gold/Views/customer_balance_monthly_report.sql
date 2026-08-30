-- Auto Generated (Do not modify) E97EED5D52717DC2570EDC13FD7BF7FCC93FAFF02110C0F1D7A06086F0130DBB
CREATE   VIEW gold.customer_balance_monthly_report AS
SELECT
    b.CustomerId,
    c.CustomerCategory,
    c.CustomerName,
    b.CountryId,
    datetrunc(month, b.InvoiceDate) as InvoiceMonth,
    sum(InvoicedAmount) as InvoicedAmount,
    sum(RemainingAmount) as Remaining,
    sum(PaymentAmount + CreditNoteAmount + RefundAmount) as SettledAmount,
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
from gold.invoice_balance_fact b
join gold.customer c
  on c.CustomerId = b.CustomerId
group by b.CustomerId, c.CustomerName, c.CustomerCategory, b.CountryId, datetrunc(month, b.InvoiceDate)
;