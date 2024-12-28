DROP TABLE IF EXISTS public.outbox;

CREATE TABLE IF NOT EXISTS public.outbox (
    id INT GENERATED ALWAYS AS IDENTITY NOT NULL, 
    object_id INT NOT NULL, 
    record_ts TIMESTAMP NOT NULL,
    type VARCHAR NOT NULL,
    payload TEXT NOT NULL,
    CONSTRAINT outbox_id PRIMARY KEY (id)
); 