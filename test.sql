WITH
    t1 AS (
        SELECT DISTINCT
            ON ("vocabulary_id") base."vocabulary_id", base."language" AS "target_lang", base."vocabulary_translation" AS "target", pgroonga_score (base.tableoid, base.ctid) AS "score", JSON_OBJECT_AGG(
                q."language", q."vocabulary_translation"
            ) OVER (
                PARTITION BY
                    base."vocabulary_id"
            ) "lan_dict"
        FROM
            "dictionary_items" base
            LEFT JOIN "dictionary_items" q ON base."vocabulary_id" = q."vocabulary_id"
        WHERE
            base."vocabulary_translation" &@~ $1
        ORDER BY base."vocabulary_id"
    ),
    t2 AS (
        SELECT TO_JSON(t1.*) AS "result", COUNT(*) OVER () AS "total"
        FROM t1
        ORDER BY LENGTH("target"), score DESC
        LIMIT $2
        OFFSET $3
    ),
    t3 AS (
        SELECT COALESCE(JSON_AGG(t2."result"), '[]'::json) AS "results"
        FROM t2
    ),
    t4 AS (
        SELECT (COUNT(*) / $2) + 1 AS "total_page"
        FROM t1
    ),
    t5 AS (
        SELECT t3."results", t4."total_page"
        FROM t3
            FULL JOIN t4 ON TRUE
    )
SELECT to_json(t5.*) AS "result!: Json<QueryResult>"
FROM t5;