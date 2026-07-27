USE `ev-vehicle-market-share`;
RENAME TABLE `vehicle data` TO vehicle_data;
select * from vehicle_data;

ALTER TABLE vehicle_data 
RENAME COLUMN `Electric (EV)` TO ev,
RENAME COLUMN `Plug-In Hybrid Electric (PHEV)` TO phev,
RENAME COLUMN `Hybrid Electric (HEV)` TO hev,
RENAME COLUMN `Ethanol/Flex (E85)` TO ethanol_flex_e85,
RENAME COLUMN `Compressed Natural Gas (CNG)` TO cng;

ALTER TABLE vehicle_data RENAME COLUMN `Unknown Fuel` TO unk_fuel;

CREATE TABLE vehicle_clean AS
SELECT
  state,
  CAST(REPLACE(ev, ',', '') AS UNSIGNED) AS ev,
  CAST(REPLACE(phev, ',', '') AS UNSIGNED) AS phev,
  CAST(REPLACE(hev, ',', '') AS UNSIGNED) AS hev,
  CAST(REPLACE(biodiesel, ',', '') AS UNSIGNED) AS biodiesel,
  CAST(REPLACE(ethanol_flex_e85, ',', '') AS UNSIGNED) AS ethanol_flex_e85,
  CAST(REPLACE(cng, ',', '') AS UNSIGNED) AS cng,
  CAST(REPLACE(propane, ',', '') AS UNSIGNED) AS propane,
  CAST(REPLACE(hydrogen, ',', '') AS UNSIGNED) AS hydrogen,
  CAST(REPLACE(gasoline, ',', '') AS UNSIGNED) AS gasoline,
  CAST(REPLACE(diesel, ',', '') AS UNSIGNED) AS diesel,
  CAST(REPLACE(unk_fuel, ',', '') AS UNSIGNED) AS unk_fuel
FROM vehicle_data;
select * from vehicle_clean;

-- dropping methanol since zero everywhere
alter table vehicle_data drop column Methanol;
select count(*)-count(ev) as ev_null ,
	count(*)-count(phev) as phev_null,
    count(*)-count(hev) as hev_null ,
    count(*)-count(biodiesel) as bd_null ,
    count(*)-count(ethanol_flex_e85) as ef85_null ,
    count(*)-count(cng) as cng_null ,
    count(*)-count(propane) as propane_null ,
    count(*)-count(hydrogen) as hyd_null ,
    count(*)-count(gasoline) as gasoline_null ,
    count(*)-count(diesel) as diesel_null,
    count(*)-count(unk_fuel) as cng_null from vehicle_data;
    
SELECT state, 
  (ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel) AS total
FROM vehicle_clean
ORDER BY total DESC
LIMIT 5;

select * from vehicle_clean;


WITH percent AS (
  SELECT state,
    (ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel) AS total_vehicles,
    ev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_ev,
phev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_phev,
hev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_hev,
biodiesel/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_biodiesel,
ethanol_flex_e85/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_ef85,
cng/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_cng,
propane/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_propane,
hydrogen/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_hyd,
gasoline/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_gasoline,
unk_fuel/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_unk_fuel
  FROM vehicle_clean
)select * from percent;

-- percentage of EVs, PHEVs, HEVs, and Gasoline vehicles for each state.
-- Identify the top 5 states with the highest EV adoption rate 
with percent as(
SELECT state,(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel) as total_vehicles,
ev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_ev,
phev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_phev,
hev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_hev,
biodiesel/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_biodiesel,
ethanol_flex_e85/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_ef85,
cng/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_cng,
propane/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_propane,
hydrogen/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_hyd,
gasoline/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_gasoline,
unk_fuel/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_unk_fuel
 from vehicle_clean
)select state,dense_rank() over(order by percent_ev desc) as state_rank,percent_ev,percent_phev,percent_hev,percent_gasoline from percent limit 5;


-- bottom 5
SELECT state,
(ev*1.0)/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 
AS percent_ev
FROM vehicle_clean
ORDER BY percent_ev ASC
LIMIT 5;

-- comparison of cs with bigger states like ny, texas, florida
WITH percent AS (
  SELECT state,
    (ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel) AS total_vehicles,
    ev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_ev,
    phev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_phev,
    hev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_hev,
    gasoline/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_gasoline
  FROM vehicle_clean
)
SELECT state, total_vehicles, percent_ev, percent_phev, percent_hev, percent_gasoline
FROM percent
WHERE state IN ('California', 'Texas', 'Florida', 'New York')
ORDER BY percent_ev DESC;


-- trends and insights
WITH percent AS (
  SELECT state,
    (ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel) AS total_vehicles,
    biodiesel/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_biodiesel,
    ethanol_flex_e85/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_ef85,
    hydrogen/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_hyd
  FROM vehicle_clean
)
SELECT
  AVG(percent_biodiesel) AS avg_biodiesel_pct,
  AVG(percent_ef85) AS avg_ethanol_pct,
  AVG(percent_hyd) AS avg_hydrogen_pct,
  SUM(CASE WHEN percent_biodiesel > 0.5 THEN 1 ELSE 0 END) AS states_with_meaningful_biodiesel,
  SUM(CASE WHEN percent_ef85 > 0.5 THEN 1 ELSE 0 END) AS states_with_meaningful_ethanol,
  SUM(CASE WHEN percent_hyd > 0.5 THEN 1 ELSE 0 END) AS states_with_meaningful_hydrogen
FROM percent;



CREATE TABLE vehicle_market_share AS
WITH percent AS (
  SELECT state,
    (ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel) AS total_vehicles,
    ev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_ev,
    phev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_phev,
    hev/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_hev,
    biodiesel/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_biodiesel,
    ethanol_flex_e85/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_ef85,
    hydrogen/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_hyd,
    gasoline/(ev+phev+hev+biodiesel+ethanol_flex_e85+cng+propane+hydrogen+gasoline+diesel+unk_fuel)*100 AS percent_gasoline
  FROM vehicle_clean
)
SELECT * FROM percent; 

select * from vehicle_market_share ;