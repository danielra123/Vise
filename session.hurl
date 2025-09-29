# Card restrictions

# Classic - should register without restrictions
POST {{host}}/client
{
  "name": "Alice Classic",
  "country": "USA",
  "monthlyIncome": 100,
  "viseClub": false,
  "cardType": "Classic"
}
HTTP 200
[Captures]
classic_id: jsonpath "$['clientId']"
[Asserts]
jsonpath "$.status" == "Registered"
jsonpath "$.cardType" == "Classic"


# Gold - valid case (income >= 500)
POST {{host}}/client
{
  "name": "Bob Gold",
  "country": "USA",
  "monthlyIncome": 600,
  "viseClub": false,
  "cardType": "Gold"
}
HTTP 200
[Captures]
gold_id: jsonpath "$['clientId']"
[Asserts]
jsonpath "$.status" == "Registered"
jsonpath "$.cardType" == "Gold"


# Gold - invalid case (income < 500)
POST {{host}}/client
{
  "name": "Charlie Gold",
  "country": "USA",
  "monthlyIncome": 400,
  "viseClub": false,
  "cardType": "Gold"
}
HTTP *
[Asserts]
jsonpath "$.status" == "Rejected"

# Platinum - valid case (income >= 1000, Vise CLUB)
POST {{host}}/client
{
  "name": "Bob Gold",
  "country": "USA",
  "monthlyIncome": 1200,
  "viseClub": true,
  "cardType": "Platinum"
}
HTTP 200
[Captures]
platinum_id: jsonpath "$['clientId']"
[Asserts]
jsonpath "$.status" == "Registered"
jsonpath "$.cardType" == "Platinum"

# Platinum - invalid (income < 1000, missing VISE CLUB)
POST {{host}}/client
{
  "name": "Diana Platinum",
  "country": "USA",
  "monthlyIncome": 200,
  "viseClub": false,
  "cardType": "Platinum"
}
HTTP *
[Asserts]
jsonpath "$.status" == "Rejected"

# Black - valid case (income >= 2000, Vise CLUB, USA country)
POST {{host}}/client
{
  "name": "Bob Gold",
  "country": "USA",
  "monthlyIncome": 2100,
  "viseClub": true,
  "cardType": "Black"
}
HTTP 200
[Captures]
black_id: jsonpath "$['clientId']"
[Asserts]
jsonpath "$.status" == "Registered"
jsonpath "$.cardType" == "Black"

# Black - invalid (restricted country)
POST {{host}}/client
{
  "name": "Eve Black",
  "country": "China",
  "monthlyIncome": 1400,
  "viseClub": false,
  "cardType": "Black"
}
HTTP *
[Asserts]
jsonpath "$.status" == "Rejected"

# White - valid case (income >= 2000, Vise CLUB, USA country)
POST {{host}}/client
{
  "name": "Bob Gold",
  "country": "USA",
  "monthlyIncome": 2100,
  "viseClub": true,
  "cardType": "White"
}
HTTP 200
[Captures]
white_id: jsonpath "$['clientId']"
[Asserts]
jsonpath "$.status" == "Registered"
jsonpath "$.cardType" == "White"

# White - invalid (restricted country)
POST {{host}}/client
{
  "name": "Eve Peters",
  "country": "China",
  "monthlyIncome": 1400,
  "viseClub": false,
  "cardType": "White"
}
HTTP *
[Asserts]
jsonpath "$.status" == "Rejected"


# Purchase benefits

# Gold: Monday purchase >100 -> 15% discount
POST {{host}}/purchase
{
  "clientId": {{ gold_id }},
  "amount": 200,
  "currency": "USD",
  "purchaseDate": "2025-09-29",
  "purchaseCountry": "USA"
}
HTTP 200
[Asserts]
jsonpath "$.status" == "Approved"
jsonpath "$.purchase.discountApplied" == 30
jsonpath "$.purchase.finalAmount" == 170
jsonpath "$.purchase.benefit" contains "15%"


# Platinum: Saturday purchase >200 -> 30% discount
POST {{host}}/purchase
{
  "clientId": {{ platinum_id }},
  "amount": 250,
  "currency": "USD",
  "purchaseDate": "2025-09-27",
  "purchaseCountry": "USA"
}
HTTP 200
[Asserts]
jsonpath "$.status" == "Approved"
jsonpath "$.purchase.discountApplied" == 75
jsonpath "$.purchase.finalAmount" == 175
jsonpath "$.purchase.benefit" contains "30%"

# Platinum: Mon-Wed, >100 USD, 20%
POST {{host}}/purchase
{
  "clientId": {{ platinum_id }},
  "amount": 200,
  "currency": "USD",
  "purchaseDate": "2025-09-30",
  "purchaseCountry": "USA"
}
HTTP 200
[Asserts]
jsonpath "$.purchase.discountApplied" == 40
jsonpath "$.purchase.finalAmount" == 160
jsonpath "$.purchase.benefit" contains "20%"

# Platinum: Foreign purchase, 5%
POST {{host}}/purchase
Content-Type: application/json
{
  "clientId": {{ platinum_id }},
  "amount": 100,
  "currency": "USD",
  "purchaseDate": "2025-10-02",
  "purchaseCountry": "France"
}
HTTP 200
[Asserts]
jsonpath "$.purchase.discountApplied" == 5
jsonpath "$.purchase.finalAmount" == 95
jsonpath "$.purchase.benefit" contains "5%"

# Black: Mon-Wed, >100 USD, 25%
POST {{host}}/purchase
{
  "clientId": {{ black_id }},
  "amount": 200,
  "currency": "USD",
  "purchaseDate": "2025-10-01",
  "purchaseCountry": "USA"
}
HTTP 200
[Asserts]
jsonpath "$.purchase.discountApplied" == 50
jsonpath "$.purchase.finalAmount" == 150
jsonpath "$.purchase.benefit" contains "25%"

# Black: Saturday, >200 USD, 35%
POST {{host}}/purchase
{
  "clientId": {{ black_id }},
  "amount": 260,
  "currency": "USD",
  "purchaseDate": "2025-10-04",
  "purchaseCountry": "USA"
}
HTTP/1.1 200
[Asserts]
jsonpath "$.purchase.discountApplied" == 91
jsonpath "$.purchase.finalAmount" == 169
jsonpath "$.purchase.benefit" contains "35%"

# Black: Foreign purchase, 5%
POST {{host}}/purchase
{
  "clientId": {{ black_id }},
  "amount": 100,
  "currency": "USD",
  "purchaseDate": "2025-10-02",
  "purchaseCountry": "Germany"
}
HTTP 200
[Asserts]
jsonpath "$.purchase.discountApplied" == 5
jsonpath "$.purchase.finalAmount" == 95
jsonpath "$.purchase.benefit" contains "5%"

# White: Mon-Fri, >100 USD, 25%
POST {{host}}/purchase
{
  "clientId": {{ white_id }},
  "amount": 200,
  "currency": "USD",
  "purchaseDate": "2025-09-30",
  "purchaseCountry": "USA"
}
HTTP 200
[Asserts]
jsonpath "$.purchase.discountApplied" == 50
jsonpath "$.purchase.finalAmount" == 150
jsonpath "$.purchase.benefit" contains "25%"

# White: Sat-Sun, >200 USD, 35%
POST {{host}}/purchase
{
  "clientId": {{ white_id }},
  "amount": 260,
  "currency": "USD",
  "purchaseDate": "2025-10-05",
  "purchaseCountry": "USA"
}
HTTP 200
[Asserts]
jsonpath "$.purchase.discountApplied" == 91
jsonpath "$.purchase.finalAmount" == 169
jsonpath "$.purchase.benefit" contains "35%"

# White: Foreign purchase, 5%
POST {{host}}/purchase
{
  "clientId": {{ white_id }},
  "amount": 100,
  "currency": "USD",
  "purchaseDate": "2025-10-02",
  "purchaseCountry": "Brazil"
}
HTTP 200
[Asserts]
jsonpath "$.purchase.discountApplied" == 5
jsonpath "$.purchase.finalAmount" == 95
jsonpath "$.purchase.benefit" contains "5%"
