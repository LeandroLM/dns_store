# DNS Store

This project is a simple API for storing DNS records and their associated hostnames.

## Installation

Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) and [PostgreSQL](https://www.postgresql.org/).

Clone the project:

`git clone git@github.com:LeandroLM/dns_store.git`


Install bundler:

`bundle install`

From the project folder, run `bundle install` to install all the dependencies.

Create a copy of `config/database.yml.example` called `config/database.yml` and edit it with your local database credentials.

```yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: postgres
  password: postgres
```

Start a local server:

`rails s`

## API

The API has two endpoints. One for creating a DNS record and associating it with hostnames. The second returns DNS records and their hostnames matching some criteria.

### Endpoint 1

It acepts POST requests to `/api/dns` and creates a DNS record and associated hostnames. The ip address is required and must have a valid IPv4 format. At least one hostname is required.

The request body must have this format:

```json
{
  "dns": {
    "ip_address": "4.4.4.4",
    "hostnames": ["ipsum.com", "dolor.com", "sit.amet", "amet.com"]
  }
}
```

### Endpoint 2

It acepts POST requests to `/api/dns/list` and return DNS records matching some criteria.

It optionally can receive a list of hostnames to include and a list to exclude. A page parameter is required.

It returns a list of all DNS records that has all the hostname it should include, but none it should exclude. It also returns all hostnames associated with the matching DNS records that are not in either list, along with a counter indicating in how many records that hostname did appear.

For example, if the following DNS records and hostnames are stored in the database:

1. IP `1.1.1.1` with hostnames `lorem.com`, `ipsum.com`, `dolor.com`, `amet.com`
2. IP `2.2.2.2` with hostname `lorem.com`
3. IP `3.3.3.3` with hostnames `ipsum.com`, `dolor.com`, `amet.com`
4. IP `4.4.4.4` with hostnames `ipsum.com`, `dolor.com`, `sit.com`, `amet.com`
5. IP `5.5.5.5` with hostnames `dolor.com`, `sit.com`


Given a request with the following body

```json
{
  "page": 1,
  "include": ["ipsum.com", "dolor.com"],
  "exclude": ["sit.com"]
}
```

The API responds with

```json
{
  "data": {
    "dns_records_count": 2,
    "dns_records": [
      {
        "id": 1,
        "ip_address": "1.1.1.1"
      },
      {
        "id": 3,
        "ip_address": "3.3.3.3"
      }
    ],
    "hostnames": [
      {
        "hostname": "lorem.com",
        "matching_dns_records": 1
      },
      {
        "hostname": "amet.com",
        "matching_dns_records": 2
      }
    ]
  }
}
```
### Example

To test the API, you can populate the databae with data from the example above. Just run these commands from you shell:

```shell
curl --request POST \
  --url http://localhost:3000/api/dns \
  --header 'content-type: application/json' \
  --data '{
  "dns": {
    "ip_address": "1.1.1.1",
    "hostnames": ["lorem.com", "ipsum.com", "dolor.com", "amet.com"]
  }
}'
```

```shell
curl --request POST \
  --url http://localhost:3000/api/dns \
  --header 'content-type: application/json' \
  --data '{
  "dns": {
    "ip_address": "2.2.2.2",
    "hostnames": ["ipsum.com"]
  }
}'
```

```shell
curl --request POST \
  --url http://localhost:3000/api/dns \
  --header 'content-type: application/json' \
  --data '{
  "dns": {
    "ip_address": "3.3.3.3",
    "hostnames": ["ipsum.com", "dolor.com", "amet.com"]
  }
}'
```

```shell
curl --request POST \
  --url http://localhost:3000/api/dns \
  --header 'content-type: application/json' \
  --data '{
  "dns": {
    "ip_address": "4.4.4.4",
    "hostnames": ["ipsum.com", "dolor.com", "sit.com", "amet.com"]
  }
}'
```

```shell
curl --request POST \
  --url http://localhost:3000/api/dns \
  --header 'content-type: application/json' \
  --data '{
  "dns": {
    "ip_address": "5.5.5.5",
    "hostnames": ["dolor.com", "sit.com"]
  }
}'
```

And to list the DNS records matching the criteria above:

```shell
curl --request POST \
  --url http://localhost:3000/api/dns/list \
  --header 'content-type: application/json' \
  --data '{
  "page": 1,
  "include": ["ipsum.com", "dolor.com"],
  "exclude": ["sit.com"]
}'
```

### Testing

To run all the tests, run `rspec` from the project root folder. Alternatively, you can run `rspec --format doc` to see a description of each test example.

### Live Demo

A live demo of the project is running in Heroku on https://fierce-peak-22605.herokuapp.com/.

To run the same query as above pointing to the live demo:

```shell
curl --request POST \
  --url https://fierce-peak-22605.herokuapp.com/api/dns/list \
  --header 'content-type: application/json' \
  --data '{
  "page": 1,
  "include": ["ipsum.com", "dolor.com"],
  "exclude": ["sit.com"]
}'
```

