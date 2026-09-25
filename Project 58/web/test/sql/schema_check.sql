-- Run against an empty database after priv/repo/structure.sql. Any failed check raises and stops.
\set ON_ERROR_STOP on
CREATE FUNCTION must_fail(q text, label text) RETURNS void AS $$
BEGIN
  BEGIN EXECUTE q; EXCEPTION WHEN others THEN RAISE NOTICE 'PASS refused: %', label; RETURN; END;
  RAISE EXCEPTION 'FAIL allowed: %', label;
END $$ LANGUAGE plpgsql;

INSERT INTO business_lines (slug,name,inserted_at,updated_at) VALUES ('last-ten-yards','Last Ten Yards',now(),now()), ('pharmadash','Pharmadash',now(),now());
SELECT must_fail($q$INSERT INTO business_lines (slug,name,inserted_at,updated_at) VALUES ('pharmadash','Dup',now(),now())$q$, 'duplicate line');
SELECT must_fail($q$INSERT INTO business_lines (slug,name,inserted_at,updated_at) VALUES ('Bad Line','X',now(),now())$q$, 'bad line slug');
INSERT INTO products (slug,name,cents,stripe_price,business_line_id,inserted_at,updated_at) VALUES ('ride-at-closing','Ride at Closing',2500,'price_1',(SELECT id FROM business_lines WHERE slug='last-ten-yards'),now(),now());
INSERT INTO products (slug,name,cents,stripe_price,business_line_id,inserted_at,updated_at) VALUES ('rx-run','Rx Run',900,'price_rx',(SELECT id FROM business_lines WHERE slug='pharmadash'),now(),now());
DO $$ BEGIN IF (SELECT count(*) FROM products p JOIN business_lines l ON l.id=p.business_line_id WHERE l.slug='pharmadash') <> 1 THEN RAISE EXCEPTION 'FAIL per-line shelf'; END IF; RAISE NOTICE 'PASS each line has its own shelf'; END $$;
SELECT must_fail($q$DELETE FROM business_lines WHERE slug='pharmadash'$q$, 'deleting a line that still has products');
SELECT must_fail($q$INSERT INTO products (slug,name,cents,stripe_price,business_line_id,inserted_at,updated_at) VALUES ('orphan','X',100,'price_o',999999,now(),now())$q$, 'product on unknown line');
SELECT must_fail($q$INSERT INTO products (slug,name,cents,stripe_price,inserted_at,updated_at) VALUES ('ride-at-closing','Dup',100,'price_2',now(),now())$q$, 'duplicate slug');
SELECT must_fail($q$INSERT INTO products (slug,name,cents,stripe_price,inserted_at,updated_at) VALUES ('free','Free',0,'price_3',now(),now())$q$, 'zero price');
SELECT must_fail($q$INSERT INTO products (slug,name,cents,stripe_price,inserted_at,updated_at) VALUES ('Bad Slug','X',100,'price_4',now(),now())$q$, 'bad slug');
SELECT must_fail($q$INSERT INTO products (slug,name,cents,stripe_price,inserted_at,updated_at) VALUES ('keyleak','X',100,'sk_live_1',now(),now())$q$, 'secret key as price');
SELECT must_fail($q$INSERT INTO products (slug,name,cents,stripe_price,inserted_at,updated_at) VALUES ('long','$q$ || repeat('a',81) || $q$',100,'price_5',now(),now())$q$, 'name over 80');

INSERT INTO orders (stripe_session_id,payment_intent,amount_cents,product_id,inserted_at,updated_at)
  VALUES ('cs_1','pi_1',2500,(SELECT id FROM products WHERE slug='ride-at-closing'),now(),now());
-- Stripe resends: the second insert is a no-op, not a second order
INSERT INTO orders (stripe_session_id,amount_cents,inserted_at,updated_at) VALUES ('cs_1',2500,now(),now()) ON CONFLICT (stripe_session_id) DO NOTHING;
DO $$ BEGIN IF (SELECT count(*) FROM orders) <> 1 THEN RAISE EXCEPTION 'FAIL resend made a second order'; END IF; RAISE NOTICE 'PASS resend is a no-op'; END $$;
SELECT must_fail($q$INSERT INTO orders (stripe_session_id,amount_cents,inserted_at,updated_at) VALUES ('cs_1',1,now(),now())$q$, 'duplicate session');
SELECT must_fail($q$INSERT INTO orders (stripe_session_id,amount_cents,status,inserted_at,updated_at) VALUES ('cs_2',1,'pending',now(),now())$q$, 'unknown status');
SELECT must_fail($q$INSERT INTO orders (stripe_session_id,amount_cents,inserted_at,updated_at) VALUES ('cs_3',-1,now(),now())$q$, 'negative amount');
SELECT must_fail($q$INSERT INTO orders (stripe_session_id,amount_cents,currency,inserted_at,updated_at) VALUES ('cs_4',1,'eur',now(),now())$q$, 'non-usd');
SELECT must_fail($q$INSERT INTO orders (stripe_session_id,amount_cents,product_id,inserted_at,updated_at) VALUES ('cs_5',1,999999,now(),now())$q$, 'unknown product');
DO $$ BEGIN
  IF (SELECT status FROM orders WHERE stripe_session_id='cs_1') <> 'paid' THEN RAISE EXCEPTION 'FAIL default status'; END IF;
  IF (SELECT currency FROM orders WHERE stripe_session_id='cs_1') <> 'usd' THEN RAISE EXCEPTION 'FAIL default currency'; END IF;
  RAISE NOTICE 'PASS defaults paid/usd'; END $$;
UPDATE orders SET status='refunded' WHERE payment_intent='pi_1';
DO $$ BEGIN IF (SELECT status FROM orders WHERE payment_intent='pi_1') <> 'refunded' THEN RAISE EXCEPTION 'FAIL refund'; END IF; RAISE NOTICE 'PASS refund by payment intent'; END $$;
DELETE FROM products WHERE slug='ride-at-closing';
DO $$ BEGIN IF (SELECT product_id FROM orders WHERE stripe_session_id='cs_1') IS NOT NULL THEN RAISE EXCEPTION 'FAIL nilify'; END IF; RAISE NOTICE 'PASS deleting a product keeps its orders'; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name ~ '(card|email|phone|address|name)') THEN RAISE EXCEPTION 'FAIL orders hold buyer data'; END IF; RAISE NOTICE 'PASS orders hold no card or buyer contact columns'; END $$;
