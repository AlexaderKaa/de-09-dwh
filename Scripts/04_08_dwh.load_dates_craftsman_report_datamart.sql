SELECT 
	MAX(
		GREATEST(  
			COALESCE(craftsman_load_dttm, NOW())
			,COALESCE(customers_load_dttm, NOW())
  			,COALESCE(products_load_dttm, NOW())
  				)
  		) FROM dwh.dwh_delta ;
  		
SELECT MAX(GREATEST(  COALESCE(craftsman_load_dttm, NOW())
  ,customers_load_dttm
  ,products_load_dttm)) FROM dwh.dwh_delta ;