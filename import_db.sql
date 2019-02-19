PRAGMA foreign_keys = ON;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    parent_id INTEGER,
    body TEXT NOT NULL,
    subject_question_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL, 

    FOREIGN KEY (parent_id) REFERENCES replies(id),
    FOREIGN KEY (subject_question_id) REFERENCES questions(id),
    FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
    users (fname, lname)
VALUES
    ('Bobby', 'Smith'),
    ('Smithy', 'Bobson');

INSERT INTO
    questions (title, body, user_id)
VALUES
    ('ORM', 'What is it?', (SELECT id FROM users WHERE fname = 'Bobby' AND lname = 'Smith')),
    ('Cats?', 'I don''t know anymore', (SELECT id FROM users WHERE fname = 'Smithy' AND lname = 'Bobson'));

INSERT INTO
    replies  (parent_id, body, subject_question_id, author_id)
VALUES
    (NULL, 'Incomprehensible', (SELECT id FROM questions WHERE title = 'ORM'), (SELECT id FROM users WHERE fname = 'Smithy' AND lname = 'Bobson')),
    (1, 'COMPREHENSIBLE', (SELECT id FROM questions WHERE title = 'ORM'), (SELECT id FROM users WHERE fname = 'Smithy' AND lname = 'Bobson'));

INSERT INTO
    question_follows (user_id, question_id)
VALUES
    (1,2),
    (2,1);

INSERT INTO
    question_likes (user_id, question_id)
VALUES
    (1,2),
    (2,1);
