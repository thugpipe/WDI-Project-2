DROP TABLE IF EXISTS likes CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS threads CASCADE;


CREATE TABLE users(
	id SERIAL PRIMARY KEY,
	name VARCHAR NOT NULL,
	username VARCHAR UNIQUE NOT NULL,
	password_digest VARCHAR NOT NULL
);

CREATE TABLE threads(
	id SERIAL PRIMARY KEY,
	topic VARCHAR NOT NULL,
	description VARCHAR NOT NULL,
	img_url VARCHAR
);

CREATE TABLE posts(
	id SERIAL PRIMARY KEY,
	title VARCHAR NOT NULL,
	content VARCHAR NOT NULL,
	created_by_id INTEGER NOT NULL REFERENCES users(id),
	thread_id INTEGER NOT NULL REFERENCES threads(id)
);

CREATE TABLE comments(
	id SERIAL PRIMARY KEY,
	post_id INTEGER REFERENCES posts(id),
	user_id INTEGER REFERENCES users(id),
	content VARCHAR NOT NULL,
	date_time_created TIMESTAMP
);

CREATE TABLE likes(
	id SERIAL PRIMARY KEY,
	user_id INTEGER REFERENCES users(id),
	post_id INTEGER REFERENCES posts(id)
);

-- topics = [
-- 	['Small Apartments', 'The compact spaces we choose to cram all our crap and how we do it.', null],
-- 	['Small Cars', 'Small cars dont have to be crap cars.', null],
-- 	['Small bikes', 'Whats your flavor? Folding, BMX, or Minivelo?  When space is at a premium or in a urban environment a compact ride is much easier to live with!', null],
-- 	['Small electronics', 'Small is where it is at, how many space age gadgets can you fit in your pockets?', null],
-- 	['Tiny Trains', 'Who the hell has enough space for trains in an apartment in this city O_o?', null]
-- ]
INSERT INTO threads (topic, description, img_url) VALUES('Small Apartments', 'The compact spaces we choose to cram all our crap and how we do it.', null);
INSERT INTO threads (topic, description, img_url) VALUES('Small Cars', 'Small cars dont have to be crap cars.', null);
INSERT INTO threads (topic, description, img_url) VALUES('Small bikes', 'Whats your flavor? Folding, BMX, or Minivelo?  When space is at a premium or in a urban environment a compact ride is much easier to live with!', 'https://farm4.staticflickr.com/3737/10742532246_19a7cccbb9_q.jpg');
INSERT INTO threads (topic, description, img_url) VALUES('Small electronics', 'Small is where it is at, how many space age gadgets can you fit in your pockets?', null);
INSERT INTO threads (topic, description, img_url) VALUES('Tiny Trains', 'Who the hell has enough space for trains in an apartment in this city O_o?', null);
 -- topics.each do
