-- ============================================================
--  Seed default groups + tips, authored by Nicholas.
--  Run AFTER nicholas.snogren@sprezzmc.com has signed in once
--  (so the profile row exists). Safe to re-run.
-- ============================================================
do $$
declare nick uuid;
begin
  select id into nick from profiles where email = 'nicholas.snogren@sprezzmc.com';

  -- Format & Structure
  insert into groups (id, name, position, author_id) values
    ('11111111-1111-1111-1111-111111111111', 'Format & Structure', 1, nick)
    on conflict (id) do nothing;
  insert into tips (group_id, title, body, example, author_id) values
    ('11111111-1111-1111-1111-111111111111', 'Set a word limit',
     'State the length you want before the model gets a chance to ramble. "Three bullets." "Under eighty words." It is the smallest instruction with the largest visible return — the reply lands faster and you read it faster. A language model continues the pattern your prompt starts, one token at a time; give it the shape of the ending and you have removed a whole dimension of guesswork.',
     'Summarize this report in 5 bullets, max 80 words.', nick),
    ('11111111-1111-1111-1111-111111111111', 'Specify the output',
     'Name the exact container you want back — a table, a bulleted list, an email, JSON. Naming the format saves you reformatting later and makes several answers directly comparable.',
     'Compare these 3 vendors as a table: name, cost, risk, recommendation.', nick),
    ('11111111-1111-1111-1111-111111111111', 'Clear, specific, direct',
     'Say exactly what you want, who it is for, and what to avoid. Vague prompts get vague answers; the model fills ambiguity with the average of everything it has seen.',
     'Write a 2-line email declining the vendor quote — polite, no reason given.', nick);

  -- Context & Persona
  insert into groups (id, name, position, author_id) values
    ('22222222-2222-2222-2222-222222222222', 'Context & Persona', 2, nick)
    on conflict (id) do nothing;
  insert into tips (group_id, title, body, example, author_id) values
    ('22222222-2222-2222-2222-222222222222', 'Front-load the situation',
     'Open with your situation before the ask. Every detail of who, what, and why shifts the probabilities behind each token the model generates.',
     'I''m a {role} doing {task} to achieve {goal} for {stakeholders}. Draft…', nick),
    ('22222222-2222-2222-2222-222222222222', 'Upload the evidence',
     'Screenshot the screen, paste the contract, attach the spreadsheet. It reads images, code, and tables directly — often faster than describing them.',
     'Here''s a screenshot of my Power BI screen — walk me through the next step.', nick);

  -- Variety
  insert into groups (id, name, position, author_id) values
    ('33333333-3333-3333-3333-333333333333', 'Variety', 3, nick)
    on conflict (id) do nothing;
  insert into tips (group_id, title, body, example, author_id) values
    ('33333333-3333-3333-3333-333333333333', 'Ask for many options',
     'Ask for several independent answers at once and have it show the probability of each. Verbalized sampling broadens the range and sidesteps the model''s default, most-likely response.',
     'Give 5 independent responses, each from a different persona. Show probability in X.X format.', nick);
end $$;
