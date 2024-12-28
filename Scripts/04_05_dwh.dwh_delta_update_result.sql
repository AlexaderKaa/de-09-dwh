-- создаём таблицу dwh_delta_update_result: делаем перерасчёт для существующих записей витрины данных, так как данные обновились за отчётные периоды 
-- логика похожа на insert, но нужно достать конкретные данные из DWH
DROP TABLE IF EXISTS dwh.dwh_delta_update_result;
CREATE TABLE IF NOT EXISTS dwh.dwh_delta_update_result AS ( 
    SELECT 
            T4.craftsman_id AS craftsman_id,
            T4.craftsman_name AS craftsman_name,
            T4.craftsman_address AS craftsman_address,
            T4.craftsman_birthday AS craftsman_birthday,
            T4.craftsman_email AS craftsman_email,
            T4.craftsman_money AS craftsman_money,
            T4.platform_money AS platform_money,
            T4.count_order AS count_order,
            T4.avg_price_order AS avg_price_order,
            T4.avg_age_customer AS avg_age_customer,
            T4.product_type AS top_product_category,
            T4.median_time_order_completed AS median_time_order_completed,
            T4.count_order_created AS count_order_created,
            T4.count_order_in_progress AS count_order_in_progress,
            T4.count_order_delivery AS count_order_delivery, 
            T4.count_order_done AS count_order_done, 
            T4.count_order_not_done AS count_order_not_done,
            T4.report_period AS report_period 
            FROM (
                SELECT     -- в этой выборке объединяем две внутренние выборки по расчёту столбцов витрины и применяем оконную функцию, чтобы определить самую популярную категорию товаров
                        *,
                        RANK() OVER(PARTITION BY T2.craftsman_id ORDER BY count_product DESC) AS rank_count_product 
                        FROM (
                            SELECT -- в этой выборке делаем расчёт по большинству столбцов, так как все они требуют одной и той же группировки, кроме столбца с самой популярной категорией товаров у мастера. Для этого столбца сделаем отдельную выборку с другой группировкой и выполним join
                                T1.craftsman_id AS craftsman_id,
                                T1.craftsman_name AS craftsman_name,
                                T1.craftsman_address AS craftsman_address,
                                T1.craftsman_birthday AS craftsman_birthday,
                                T1.craftsman_email AS craftsman_email,
                                SUM(T1.product_price) - (SUM(T1.product_price) * 0.1) AS craftsman_money,
                                SUM(T1.product_price) * 0.1 AS platform_money,
                                COUNT(order_id) AS count_order,
                                AVG(T1.product_price) AS avg_price_order,
                                AVG(T1.customer_age) AS avg_age_customer,
                                PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY diff_order_date) AS median_time_order_completed,
                                SUM(CASE WHEN T1.order_status = 'created' THEN 1 ELSE 0 END) AS count_order_created, 
                                SUM(CASE WHEN T1.order_status = 'in progress' THEN 1 ELSE 0 END) AS count_order_in_progress, 
                                SUM(CASE WHEN T1.order_status = 'delivery' THEN 1 ELSE 0 END) AS count_order_delivery, 
                                SUM(CASE WHEN T1.order_status = 'done' THEN 1 ELSE 0 END) AS count_order_done, 
                                SUM(CASE WHEN T1.order_status != 'done' THEN 1 ELSE 0 END) AS count_order_not_done,
                                T1.report_period AS report_period
                                FROM (
                                    SELECT     -- в этой выборке достаём из DWH обновлённые или новые данные по мастерам, которые уже присутствуют в витрине
                                            dc.craftsman_id AS craftsman_id,
                                            dc.craftsman_name AS craftsman_name,
                                            dc.craftsman_address AS craftsman_address,
                                            dc.craftsman_birthday AS craftsman_birthday,
                                            dc.craftsman_email AS craftsman_email,
                                            fo.order_id AS order_id,
                                            dp.product_id AS product_id,
                                            dp.product_price AS product_price,
                                            dp.product_type AS product_type,
                                            DATE_PART('year', AGE(dcs.customer_birthday)) AS customer_age, -- напишите код здесь
                                            fo.order_completion_date - fo.order_created_date AS diff_order_date, -- напишите код здесь
                                            fo.order_status AS order_status, 
                                            TO_CHAR(fo.order_created_date, 'yyyy-mm') AS report_period -- напишите код здесь
                                            FROM dwh.f_order fo 
                                                INNER JOIN dwh.d_craftsman dc ON fo.craftsman_id = dc.craftsman_id 
                                                INNER JOIN dwh.d_customer dcs ON fo.customer_id = dcs.customer_id 
                                                INNER JOIN dwh.d_product dp ON fo.product_id = dp.product_id
                                                INNER JOIN dwh.dwh_update_delta ud ON fo.craftsman_id = ud.craftsman_id
                                ) AS T1
                                    GROUP BY T1.craftsman_id, T1.craftsman_name, T1.craftsman_address, T1.craftsman_birthday, T1.craftsman_email, T1.report_period -- напишите код здесь
                            ) AS T2 
                                INNER JOIN (
                                    SELECT     -- эта выборка поможет определить самый популярный товар у мастера. Выборка не делается в предыдущем запросе, так как нужна другая группировка. Для данных этой выборки можно применить оконную функцию, которая и покажет самую популярную категорию товаров у мастера
                                            dd.craftsman_id AS craftsman_id_for_product_type, 
                                            dd.product_type, 
                                            COUNT(dd.product_id) AS count_product
                                            FROM dwh.dwh_delta AS dd
                                                GROUP BY dd.craftsman_id, dd.product_type
                                                    ORDER BY count_product DESC) AS T3 ON T2.craftsman_id = T3.craftsman_id_for_product_type
                ) AS T4 WHERE T4.rank_count_product = 1 ORDER BY report_period
);
 
-- проверка данных
-- SELECT * FROM dwh.dwh_delta_update_result;