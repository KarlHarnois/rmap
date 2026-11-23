UPDATE items SET priority = MIN(4, MAX(0, 3 - priority));
