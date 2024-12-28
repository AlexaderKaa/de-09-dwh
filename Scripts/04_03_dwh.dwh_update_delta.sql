-- создаём таблицу dwh.dwh_update_delta: делаем выборку мастеров, по которым были изменения в DWH. Данные по этим мастерам нужно будет обновить в витрине.
DROP TABLE IF EXISTS dwh.dwh_update_delta;
CREATE TABLE IF NOT EXISTS dwh.dwh_update_delta AS (
	SELECT 	
			dd.exist_craftsman_id AS craftsman_id
			FROM dwh.dwh_delta dd 
				WHERE dd.exist_craftsman_id IS NOT NULL		
);

-- проверка данных
-- SELECT * FROM dwh.dwh_update_delta;