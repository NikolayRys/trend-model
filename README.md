# Model for Reddit Trend

This project is a webserver plus a collection of scripts for preparation of the training dataset.
The dataset is used to generate a prediction Model, deployed on the Google Cloud Platform AutoML service.

Done as a part of the final group project of the team t2g0-5ca, consisted of Nikolay, Tim and Erik.
CM2020 Agile software projects, September 2021.

# Usage
## Setup
* First, install the necessary version of Ruby: `rvm install 3.0.2`
* Then, install dependencies with `bundle install`.

## To prepare dataset
* Download the Reddit data for some month from https://files.pushshift.io/reddit/submissions/
* Create a database `bundle exec ruby build_db.rb`
* Parse and analyze the reddit data into the db with `bundle exec ruby build_dataset.rb`
* Then make it into the CSV file fit for the model training: `bundle exec ruby build_csv.rb`

## Train and use the model
* Upload the produced dataset to Google AutoML
* Setup a training pipeline for tabular regression.
* Deploy the trained model when it's completed and tested
* Fill the credentials for it and then run the server script that will make use of this model: `bundle exec ruby server.rb`
