SELECT
    tp.*,
    w2.WORKSHOP_NAME,
    w2.EN_WORKSHOP_NAME,
    pl2.PRODUCT_LINE_NAME,
    pl2.EN_PRODUCT_LINE_NAME
FROM
    (
        SELECT
            mos.WORKSHOP_CODE,
            mos.PRODUCT_LINE_CODE,
            mos.PROCESS_STEP_CODE,
            TRUNC(mos.CREATED_TIMESTAMP) as CREATED_DATE,
            EXTRACT(HOUR FROM mos.CREATED_TIMESTAMP) AS CREATED_HOUR,
            COUNT(DISTINCT MODULE_NO) AS moduleNum
        FROM
            BOWAY_FORMAL.PRODUCT_LINE pl
        INNER JOIN
            (
                SELECT
                s1.MODULE_NO,
                s1.WORK_ORDER_NO,
                s1.WORKBENCH_CODE,
                s1.CREATED_TIMESTAMP,
                s1.PROCESS_STEP_CODE,
                s1.WORKSHOP_CODE,
                s1.PRODUCT_LINE_CODE,
                ROW_NUMBER() OVER
                    (
                        PARTITION BY
                            s1.MODULE_NO,
                            s1.PROCESS_STEP_CODE
                        ORDER BY
                            s1.CREATED_TIMESTAMP ASC
                    ) as rn1
                FROM
                BOWAY_FORMAL.MODULE_OVER_STATION s1
            ) mos
        ON
            pl.PRODUCT_LINE_CODE = mos.PRODUCT_LINE_CODE
        AND
            rn1 = 1
        LEFT JOIN
            BOWAY_FORMAL.WORK_ORDER wo
        ON
            wo.WORK_ORDER_NO = mos.WORK_ORDER_NO
        where
            mos.WORKSHOP_CODE IS NOT NULL
        AND
            mos.PROCESS_STEP_CODE IS NOT NULL
        AND
            mos.PRODUCT_LINE_CODE IS NOT NULL
--        AND
--            TRUNC(mos.CREATED_TIMESTAMP) > TRUNC(SYSDATE) - 7
        AND
        	mos.PROCESS_STEP_CODE = 'Binning'
        AND 
        trunc(mos.created_timestamp) - (
		        case
		            when (extract(hour from mos.created_timestamp) < 7) then 1
		            else 0
		        END	
		    ) = trunc(sysdate) - (
		    	CASE
			    	when TO_CHAR(CURRENT_TIMESTAMP AT TIME ZONE 'America/New_York', 'HH24') < 7 THEN 1
			    	ELSE 0
			    end
		    )
		 AND
		 	case
		        when TO_CHAR(CURRENT_TIMESTAMP AT TIME ZONE 'America/New_York', 'HH24') >= 7 and TO_CHAR(CURRENT_TIMESTAMP AT TIME ZONE 'America/New_York', 'HH24') < 19 then 'Day'
		        else 'Night'  -- Night
		    end
		    =
		    case
		        when (extract(hour from mos.created_timestamp) >= 7 and extract(hour from mos.created_timestamp) < 19) then 'Day'
		        else 'Night'   -- Night
		    END
        --AND mos. WORKSHOP_CODE = #{workshopCode}  --车间
        --AND mos. PRODUCT_LINE_CODE = #{productLineCode} --产线
        --AND mos. WORK_ORDER_NO IN #{workOrderNos}  --工单
        --AND wo. SAP_ORDER_SN IN #{sapOrderNos}   --sap订单
        --AND mos. CREATED_TIMESTAMP > = #{startTime} --the transit time
        --AND mos. CREATED_TIMESTAMP <= #{endTime}
        GROUP BY
            mos.PROCESS_STEP_CODE,
            mos.WORKSHOP_CODE,
            mos.PRODUCT_LINE_CODE,
            TRUNC(mos.CREATED_TIMESTAMP),
            EXTRACT(HOUR FROM mos.CREATED_TIMESTAMP)
--        ORDER BY 
--        	mos.Created_hour ASC,
--        	mos.PRODUCT_LINE_CODE asc
    ) tp
LEFT JOIN
    BOWAY_FORMAL.WORKSHOP w2
ON
    w2.WORKSHOP_CODE = tp.WORKSHOP_CODE
LEFT JOIN
    BOWAY_FORMAL.PRODUCT_LINE pl2
ON
    pl2.PRODUCT_LINE_CODE = tp.PRODUCT_LINE_CODE



-------------------------------- NEW ZETA QUERY ----------------------------------------------------------------

SELECT 
	tp.*,
	w2.WORKSHOP_NAME,
	w2.EN_WORKSHOP_NAME,
	pl2.PRODUCT_LINE_NAME,
	pl2.EN_PRODUCT_LINE_NAME 
FROM
	(
		SELECT 
			mos.WORKSHOP_CODE,
			mos.PRODUCT_LINE_CODE,
			mos.PROCESS_STEP_CODE,
			TRUNC(mos.CREATED_TIMESTAMP) as CREATED_DATE,
            EXTRACT(HOUR FROM mos.CREATED_TIMESTAMP) AS CREATED_HOUR,
			COUNT(DISTINCT MODULE_NO) AS moduleNum
        FROM 
        	BOWAY_FORMAL.MODULE_OVER_STATION mos
        INNER JOIN 
        	BOWAY_FORMAL.WORKSHOP w 
        ON 
        	w.WORKSHOP_CODE = mos.WORKSHOP_CODE
        INNER JOIN 
        	BOWAY_FORMAL.PRODUCT_LINE pl 
        ON 
        	pl.PRODUCT_LINE_CODE = mos.PRODUCT_LINE_CODE
        LEFT JOIN 
        	BOWAY_FORMAL.WORK_ORDER wo 
        ON 
        	wo.WORK_ORDER_NO = mos.WORK_ORDER_NO
		where 
			mos.WORKSHOP_CODE IS NOT NULL 
		AND 
			mos.PROCESS_STEP_CODE IS NOT NULL 
		AND 
			mos.PRODUCT_LINE_CODE IS NOT NULL
		AND
        	mos.PROCESS_STEP_CODE = 'Binning'
        AND 
        trunc(mos.created_timestamp) - (
		        case
		            when (extract(hour from mos.created_timestamp) < 7) then 1
		            else 0
		        END	
		    ) = trunc(sysdate) - (
		    	CASE
			    	when TO_CHAR(CURRENT_TIMESTAMP AT TIME ZONE 'America/New_York', 'HH24') < 7 THEN 1
			    	ELSE 0
			    end
		    )
		 AND
		 	case
		        when TO_CHAR(CURRENT_TIMESTAMP AT TIME ZONE 'America/New_York', 'HH24') >= 7 and TO_CHAR(CURRENT_TIMESTAMP AT TIME ZONE 'America/New_York', 'HH24') < 19 then 'Day'
		        else 'Night'  -- Night
		    end
		    =
		    case
		        when (extract(hour from mos.created_timestamp) >= 7 and extract(hour from mos.created_timestamp) < 19) then 'Day'
		        else 'Night'   -- Night
		    END
		GROUP BY 
			mos.PROCESS_STEP_CODE,
			mos.WORKSHOP_CODE,
			mos.PRODUCT_LINE_CODE,
			TRUNC(mos.CREATED_TIMESTAMP),
            EXTRACT(HOUR FROM mos.CREATED_TIMESTAMP)
	) tp
LEFT JOIN 
	BOWAY_FORMAL.WORKSHOP w2 
ON 
	w2.WORKSHOP_CODE = tp.WORKSHOP_CODE
LEFT JOIN 
	BOWAY_FORMAL.PRODUCT_LINE pl2 
ON 
	pl2.PRODUCT_LINE_CODE = tp.PRODUCT_LINE_CODE
