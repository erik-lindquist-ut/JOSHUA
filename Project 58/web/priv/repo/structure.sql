-- What the three migrations build, as plain SQL. Proven against real Postgres by test/sql/schema_check.sql.
CREATE TABLE business_lines (
  id bigserial PRIMARY KEY,
  slug varchar(255) NOT NULL,
  name varchar(80) NOT NULL,
  tagline varchar(160),
  source varchar(255),
  active boolean NOT NULL DEFAULT true,
  position integer NOT NULL DEFAULT 0,
  inserted_at timestamp(0) NOT NULL,
  updated_at timestamp(0) NOT NULL,
  CONSTRAINT line_slug_shape CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$')
);
CREATE UNIQUE INDEX business_lines_slug_index ON business_lines (slug);

CREATE TABLE products (
  id bigserial PRIMARY KEY,
  slug varchar(255) NOT NULL,
  name varchar(80) NOT NULL,
  blurb text,
  cents integer NOT NULL,
  stripe_price varchar(255) NOT NULL,
  active boolean NOT NULL DEFAULT true,
  position integer NOT NULL DEFAULT 0,
  business_line_id bigint REFERENCES business_lines(id) ON DELETE RESTRICT,
  inserted_at timestamp(0) NOT NULL,
  updated_at timestamp(0) NOT NULL,
  CONSTRAINT cents_positive CHECK (cents > 0),
  CONSTRAINT slug_shape CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  CONSTRAINT stripe_price_shape CHECK (stripe_price LIKE 'price\_%')
);
CREATE UNIQUE INDEX products_slug_index ON products (slug);
CREATE INDEX products_business_line_id_index ON products (business_line_id);

CREATE TABLE orders (
  id bigserial PRIMARY KEY,
  stripe_session_id varchar(255) NOT NULL,
  payment_intent varchar(255),
  amount_cents integer NOT NULL,
  currency varchar(3) NOT NULL DEFAULT 'usd',
  status varchar(255) NOT NULL DEFAULT 'paid',
  product_id bigint REFERENCES products(id) ON DELETE SET NULL,
  inserted_at timestamp(0) NOT NULL,
  updated_at timestamp(0) NOT NULL,
  CONSTRAINT amount_nonneg CHECK (amount_cents >= 0),
  CONSTRAINT status_known CHECK (status IN ('paid','refunded')),
  CONSTRAINT currency_usd CHECK (currency = 'usd')
);
CREATE UNIQUE INDEX orders_stripe_session_id_index ON orders (stripe_session_id);
CREATE INDEX orders_payment_intent_index ON orders (payment_intent);
CREATE INDEX orders_product_id_index ON orders (product_id);
