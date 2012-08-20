Feature: create models with hydra attributes
  When create model with hydra attributes
  Then hydra attributes should be saved with default values

  When hydra set is specified
  Then only attributes from this hydra set should be saved

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name    | backend_type | default_value | white_list     |
      | code    | string       | [nil:]        | [boolean:true] |
      | info    | text         | [string:]     | [boolean:true] |
      | total   | integer      | 0             | [boolean:true] |
      | price   | float        | 0             | [boolean:true] |
      | active  | boolean      | 0             | [boolean:true] |
      | started | datetime     | 2012-01-01    | [boolean:true] |

  Scenario: don't pass any hydra attributes
    Given create "Product" model
    Then last created "Product" should have the following attributes:
      | code    | [nil:]                |
      | info    | [string:]             |
      | price   | [float:0]             |
      | total   | [integer:0]           |
      | active  | [boolean:false]       |
      | started | [datetime:2012-01-01] |

  Scenario: pass two hydra attributes
    Given create "Product" model with attributes as "rows_hash":
      | code  | a      |
      | price | [nil:] |
    Then last created "Product" should have the following attributes:
      | code    | a                     |
      | info    | [string:]             |
      | total   | [integer:0]           |
      | price   | [nil:]                |
      | active  | [boolean:false]       |
      | started | [datetime:2012-01-01] |

  Scenario: pass all hydra attributes
    Given create "Product" model with attributes as "rows_hash":
      | code    | a          |
      | info    | b          |
      | total   | 0          |
      | price   | 2          |
      | active  | 1          |
      | started | 2012-05-05 |

    Then last created "Product" should have the following attributes:
      | code    | a                     |
      | price   | [float:2]             |
      | active  | [boolean:true]        |
      | info    | b                     |
      | started | [datetime:2012-05-05] |

  Scenario: pass only hydra_set_id
    Given create hydra sets for "Product" as "hashes":
      | name    |
      | Default |
      | General |
    And add "Product" hydra attributes to hydra set:
      | hydra attribute name | hydra set name          |
      | code                 | [array:Default]         |
      | price                | [array:Default]         |
      | active               | [array:Default,General] |
      | info                 | [array:General]         |

    When create "Product" model with attributes as "rows_hash":
      | hydra_set_id | [eval:Product.hydra_sets.find_by_name('Default').id] |
    Then table "hydra_string_products" should have 1 record:
      | entity_id              | hydra_attribute_id                                      |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('code').id] |
    And table "hydra_float_products" should have 1 record:
      | entity_id              | hydra_attribute_id                                       |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('price').id] |
    And table "hydra_boolean_products" should have 1 record:
      | entity_id              | hydra_attribute_id                                        |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('active').id] |
    And table "hydra_text_products" should have 0 records
    And table "hydra_integer_products" should have 0 records
    And table "hydra_datetime_products" should have 0 records

    When create "Product" model with attributes as "rows_hash":
      | hydra_set_id | [eval:Product.hydra_sets.find_by_name('General').id] |
    And table "hydra_boolean_products" should have 2 records:
      | entity_id              | hydra_attribute_id                                        |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('active').id] |
    And table "hydra_text_products" should have 1 record:
      | entity_id              | hydra_attribute_id                                      |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('info').id] |
    And table "hydra_string_products" should have 1 record:
      | entity_id               | hydra_attribute_id                                      |
      | [eval:Product.first.id] | [eval:Product.hydra_attributes.find_by_name('code').id] |
    And table "hydra_float_products" should have 1 record:
      | entity_id               | hydra_attribute_id                                       |
      | [eval:Product.first.id] | [eval:Product.hydra_attributes.find_by_name('price').id] |
    And table "hydra_integer_products" should have 0 records
    And table "hydra_datetime_products" should have 0 records

  Scenario: build model with all attributes, set hydra_set_id and save it
    Given create hydra sets for "Product" as "hashes":
      | name    |
      | Default |
      | General |
    And add "Product" hydra attributes to hydra set:
      | hydra attribute name | hydra set name          |
      | code                 | [array:Default]         |
      | price                | [array:Default]         |
      | active               | [array:Default,General] |
      | info                 | [array:General]         |
    When build "Product" model:
      | code    | #123       |
      | price   | 2.50       |
      | active  | 1          |
      | info    | desc       |
      | started | 2012-08-20 |
    And set "hydra_set_id" to "[eval:Product.hydra_sets.find_by_name('General').id]"
    And save model
    Then table "hydra_text_products" should have 1 record:
      | entity_id              | hydra_attribute_id                                      |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('info').id] |
    And table "hydra_boolean_products" should have 1 record:
      | entity_id              | hydra_attribute_id                                        |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('active').id] |
    And table "hydra_float_products" should have 0 records
    And table "hydra_string_products" should have 0 records
    And table "hydra_integer_products" should have 0 records
    And table "hydra_datetime_products" should have 0 records