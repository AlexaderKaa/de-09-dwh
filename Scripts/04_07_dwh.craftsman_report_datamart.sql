-- выполняем обновление показателей в отчёте по существующим мастерам
UPDATE dwh.craftsman_report_datamart updates SET
            craftsman_id = tableB.craftsman_id,
            craftsman_name = tableB.craftsman_name,
            craftsman_address = tableB.craftsman_address,
            craftsman_birthday = tableB.craftsman_birthday,
            craftsman_email = tableB.craftsman_email,
            craftsman_money = tableB.craftsman_money,
            platform_money = tableB.platform_money,
            count_order = tableB.count_order,
            avg_price_order = tableB.avg_price_order,
            avg_age_customer = tableB.avg_age_customer,
            top_product_category = tableB.top_product_category,
            median_time_order_completed = tableB.median_time_order_completed,
            count_order_created = tableB.count_order_created,
            count_order_in_progress = tableB.count_order_in_progress,
            count_order_delivery = tableB.count_order_delivery,
            count_order_done =tableB. count_order_done,
            count_order_not_done = tableB.count_order_not_done,
            report_period = tableB.report_period
	FROM (
		SELECT 
            craftsman_id,
            craftsman_name,
            craftsman_address,
            craftsman_birthday,
            craftsman_email,
            craftsman_money,
            platform_money,
            count_order,
            avg_price_order,
            avg_age_customer,
            top_product_category,
            median_time_order_completed,
            count_order_created,
            count_order_in_progress,
            count_order_delivery,
            count_order_done,
            count_order_not_done,
            report_period 
        FROM dwh.dwh_delta_update_result) AS tableB
	WHERE updates.craftsman_id = tableB.craftsman_id