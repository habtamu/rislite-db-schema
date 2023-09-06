create index concurrently idx_search_requests on core.requests using GIST (search);
CREATE INDEX concurrently index_ris_patients_on_requests ON core.requests USING btree (seqno,PatNumber);
CREATE INDEX concurrently index_ris_on_requests ON core.requests USING btree (deleted_at);
CREATE INDEX concurrently index_ris_on_auidit ON core.audit USING btree (event_time);