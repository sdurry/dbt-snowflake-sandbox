
{{ config(
    full_refresh = false
) }}

WITH RECURSIVE CalendarDates AS (
    SELECT DATEFROMPARTS(2015, 1, 1) AS calendar_date -- starting Jan 1st, 2015
    UNION ALL
    SELECT DATEADD(DAY, 1, calendar_date)
    FROM CalendarDates
    WHERE calendar_date < DATEADD(YEAR, 2, DATEFROMPARTS(YEAR(CURRENT_DATE), 1, 1)) - 1 -- until end of next year
)

SELECT
     to_varchar(calendar_date, 'YYYYMMDD') :: int as date_dwid
    ,calendar_date AS date
    ,YEAR(calendar_date) AS year
    ,QUARTER(calendar_date) AS quarter
    ,MONTH(calendar_date) AS month
    ,WEEKISO(calendar_date) AS week
    ,DAY(calendar_date) AS day

    ,year || '-Q' || quarter as year_quarter
    ,year || '-M' || right('0' || month, 2) as year_month
    ,YEAROFWEEKISO(calendar_date) || '-W' || right('0' || week, 2) as year_week

    ,(year || right('0' || month, 2)) :: int as year_month_short
    ,(YEAROFWEEKISO(calendar_date) || right('0' || week, 2)) :: int as year_week_short
    
    ,MONTHNAME(calendar_date) AS name_month
    ,DAYNAME(calendar_date) AS name_day
    ,DAYOFYEAR(calendar_date) AS day_of_year
    ,DAYOFMONTH(calendar_date) AS day_of_month
    ,DAYOFWEEKISO(calendar_date) AS day_of_week
    
    ,LAST_DAY (calendar_date, 'YEAR') AS last_day_of_year
    ,LAST_DAY (calendar_date, 'QUARTER') AS last_day_of_quarter
    ,LAST_DAY (calendar_date) AS last_day_of_month
    ,LAST_DAY (calendar_date, 'WEEK') AS last_day_of_week
    ,iff(date > current_date(), 1, 0) as is_future

FROM CalendarDates
