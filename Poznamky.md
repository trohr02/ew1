# Poznámky k řešení

## Pipelines, orchestrace

  - Možná bývalo bylo jednodušší udělat jednu pipeline, která nahrává data postupně do všech vrstev
  - Pipeline je připravená jen na "happy day scenario". Ve skutečném řešení je potřeba mít ošetřené různé chyby (např. chyby formátu souborů, chyby při loadu do Bronze)
  - Bylo by potřeba přidat nějaký orchestrační mechanismus - něco co 
      - bude spouštět nahrávání jednotlivých vrstev (případně datových oblastí) v pořadí podle toho, jaké jsou jejich závislosti
	  - bude umět reagovat na selhání pipeline
	  - bude umět sheduling na základě definovaných period a časových oken a splnění závislostí
  - Ve skutečném řešení by bylo potřeba řešit životní cyklus přijímaných souborů (kontrola, jestli soubor přišel/ nepřišel podle plánu, archivavot po jeho nahrání, řešit opakování loadu do Bronze se stejným souborem při chybě v Bronze)

## Datová kvalita

  - Čekal jsem, že v souborech bydou problémy s datovou kvalitou datumových a číselných údajů a proto, jsem udělal jednoduché řešení, které raw řádky odlívá do "bad" karanténních tabulek, pokud se nezdaří konverze na datový typ date a decimal.
  - Takové řádky ale v souberech nejsou
  - Pro reálné řešení by bylo dobré kontrolovat počet řádků v souboru a porovnat ho s počtem v minulé dávce. Pokud má soubor obsahovat Full snapshot, porovnání odhalí situaci, že soubor třeba není kompletní.
  

## Zaplacené vs. vyrovnané faktury

  - V souboru "payments" jsou transakce i jiého druhu než "Payment". Například "credit note" a "refund" , "charge" (nějaký příplatek či nedoplatek). Jedná se vlastně o data z účetní knihy.
  - Je možné se na to dívat **dvěma pohledy**:
		- A) **jestli je účet vyrovnaný** - k vyrovnání účtu přispívá "payment" i "credit note" (a další typy transakcí) 
		- B) **jestli je faktura splacená** - potom bychon brali v potaz jen transakce typu "payment"
		- Nejdříve jsem se na to díval pohledem A), ale potom, jsem si uvědomil, že pro jednoduchost a názornost bude vhodnější řešit jen platby a proto reporty vyhazuji splacení faktur jen na zíklade plateb.
		
		
		
