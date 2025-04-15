# Natixis Tech Challenge - João Lopes

Objective: create a Lighning web component to visualize the products.


-all data must be fetched from https://dummyjson.com/

-data must be retrieved and stored in SalesForce

-must be retrieved with authentication methods available on the API documentation: https://dummyjson.com/docs

-component must provide a way to consume from API and refresh records in realtime

-component must have a way to filter by name, categories, brand etc...

-component must show product pictures (at least 1 thumbnail)

-component must show the sum of all products in stock showing on the screen.

-business requirement	

each category can have a maximum of 100 products or the total sum of unitary price under $10k, without considering the amount of products in stock
Delivery: Package ready do deploy to a sandbox so we can test it.



# Pre-Deploy Steps


Add image host domain in order to load product thumbnails:


Go to: Setup -> Trusted URLs -> New Trusted URL

API Name: NAT_ProductImages

URL: https://cdn.dummyjson.com

Active: true

CSP Context: All

CSP Directions: check img-src (images)


Save the record


# Deploy


Project items listed on package.xml


# Notes


Project uses the Product2 standard object. All other items are included.
Apex tested with 100% code coverage. 
