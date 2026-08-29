-- Auto Generated (Do not modify) A8C1BB193038A517C94F16D10EB12F961D7595665BD9FA404A3C4C1E52228F08

CREATE   VIEW gold.customer_balance_report AS
SELECT
    b.CustomerId,
    CustomerCategory,
    b.CountryId,
    sum(InvoicedAmount) as Invoiced,
    sum(PaymentAmount + CreditNoteAmount + RefundAmount) as Settled,
    sum(RemainingAmount) as Remaining,
    sum(PaymentAmount + CreditNoteAmount + RefundAmount)  / nullif(sum(InvoicedAmount),0) as SettledPct,
    sum(RemainingAmount) / nullif(sum(InvoicedAmount),0) as RemainingPct
--    sum(InvoicedAmount) - sum(PaymentAmount + CreditNoteAmount + RefundAmount) - sum(RemainingAmount) as TieCheck
from gold.invoice_balance_fact b
join gold.customer c
  on c.CustomerId = b.CustomerId
group by b.CustomerId, CustomerCategory, b.CountryId
;