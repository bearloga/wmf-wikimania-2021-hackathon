here::i_am("scripts/data.R")

library(fs)
library(here)
library(tidyverse)
library(glue)

wdqs_usage_data_path <- here("data", "wdqs_usage.tsv")
wdqs_usage_data_uri <- "https://analytics.wikimedia.org/published/datasets/discovery/metrics/wdqs/basic_usage.tsv"

if (!file_exists(wdqs_usage_data_path)) {
    curl::curl_download(
        url = wdqs_usage_data_uri,
        destfile = wdqs_usage_data_path
    )
}

wdqs_usage_raw <- read_tsv(wdqs_usage_data_path) %>%
    rename(requests = events)

wdqs_usage_subsets <- list(
    homepage_traffic = list(
        description = "Wikidata Query Service homepage traffic from 2015-08-15 to 2021-04-25 calculated for Discovery Dashboards",
        data = wdqs_usage_raw %>%
            filter(path == "/") %>%
            select(-path)
    ),
    sparql_endpoint = list(
        description = "Wikidata Query Service SPARQL endpoint usage from 2015-08-15 to 2021-04-25 calculated for Discovery Dashboards",
        data = wdqs_usage_raw %>%
            filter(path == "/bigdata/namespace/wdq/sparql") %>%
            select(-path)
    ),
    ldf_endpoint = list(
        description = "Wikidata Query Service LDF endpoint usage from 2017-01-01 to 2021-04-25 calculated for Discovery Dashboards",
        data = wdqs_usage_raw %>%
            filter(path == "/bigdata/ldf") %>%
            select(-path)
    )
)

iwalk(wdqs_usage_subsets, function(wdqs_usage_subset, subset_name) {

    wdqs_usage_data <- list(
        license = "CC0-1.0",
        description = list(en = wdqs_usage_subset$description),
        sources = "[https://analytics.wikimedia.org/published/datasets/discovery/metrics/wdqs/ Legacy WDQS metrics] created with [[gerrit:plugins/gitiles/wikimedia/discovery/golden/|''Golden'' Retriever Scripts]]",
        schema = list(
            fields = list(
                list(
                    name = "date",
                    type = "string",
                    title = list(en = "Date")
                ),
                list(
                    name = "http_success",
                    type = "boolean",
                    title = list(en = "'Success' HTTP Status")
                ),
                list(
                    name = "is_automata",
                    type = "boolean",
                    title = list(en = "Automated/spider/bot")
                ),
                list(
                    name = "requests",
                    type = "number",
                    title = list(en = "Requests")
                )
            )
        ),
        data = wdqs_usage_subset$data
    )

    jsonlite::write_json(
        wdqs_usage_data,
        here("data", glue("{subset_name}.json")),
        auto_unbox = TRUE,
        pretty = TRUE,
        dataframe = "values"
    )

})
