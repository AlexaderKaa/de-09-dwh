DROP TABLE IF EXISTS dwh.load_dates_craftsman_report_datamart;

CREATE TABLE IF NOT EXISTS dwh.load_dates_craftsman_report_datamart (
-- напишите код здесь
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    load_dttm DATE NOT NULL,
    CONSTRAINT load_dates_craftsman_report_datamart_pk PRIMARY KEY (id)
);