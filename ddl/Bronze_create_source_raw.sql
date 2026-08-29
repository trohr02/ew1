DROP EXTERNAL DATA SOURCE raw;

CREATE EXTERNAL DATA SOURCE raw
WITH (LOCATION = 'https://onelake.dfs.fabric.microsoft.com/e0b84731-d951-442f-9cce-a07f2e342327/6f9295a7-f91e-444e-aade-e04bd00e5461');
