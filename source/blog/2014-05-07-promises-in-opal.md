---
title: "Promises: Handling asynchronous code in Opal"
date: 2014/05/07
author: Adam Beynon
---

When using Opal, one large omission from the stdlib are Threads. This is because javascript does not have threads, which makes asyncronous programming difficult in ruby. As javascript has increased in popularity with DOM libraries and web frameworks, callback hell was the standard way to handle asynchronous events in javascript. This was also the way events were handled in Opal applications. Until now.

### What is so great about promises?

When looking at a simple example, the benefits of promises may not be obvious:

```ruby
# old callback method
HTTP.get("url") do |response|
  puts "got response"
end

# using promises
HTTP.get("url").then do |response|
  puts "got response"
end
```

Initially the method call using a `Promise` looks just a more verbose version of the standard callback approach. The benefit of promises come through when promises are chained together. The result of the `#then` call actually returns a new `Promise` instance, which will not be resolved until the result of the first block resolves itself.

#### Callback hell

Lets take a slightly more complex example where an initial HTTP request is made for some user details, and then a second request is made using the result of the first json response:

<!--preview-->

```ruby
HTTP.get("user_details") do |response|
  HTTP.get("user_contacts?id=#{response.json[:user_id]}") do |response|
    HTTP.get("user_details?id=#{response.json[:contact_id]}") do
      puts "All finished"
    end
  end
end
```

This example quickly shows how callbacks become nested and difficult to follow as the result of each callback is passed to the next.

The `Promise` based version becomes much easier to read:

```ruby
HTTP.get("user_details").then do |response|
  HTTP.get("user_contacts?id=#{response.json[:user_id]}")
end.then do |response|
  HTTP.get("user_details?id=#{response.json[:contact_id]}")
end.then do
  puts "All finished"
end
```

#### Handling errors

Handling `HTTP` requests is a great example of where error handling in promises becomes really useful. Imagine we wanted to present an alert to the user when an error occurs with any of the above requests. We would need to check the response on each http request, which becomes very verbose. Using promises, errors get chained through each promise until a `fail` handler is detected. This can usally just come at the end of the chain. Promises are used to represent chunks of some procedure, so an error handler usually applies to any stage.

```ruby
HTTP.get("user_details").then do |response|
  HTTP.get("user_contacts?id=#{response.json[:user_id]}")
end.then do |response|
  HTTP.get("user_details?id=#{response.json[:contact_id]}")
end.then do
  puts "All finished"
end.fail do
  alert "An error occured with one of the requests"
end
```

### Composing promises

The previous example shows the case where one part of the promise chain relies on the previous part. Another common case is waiting for multiple parts to resolve before either performing an action, or showing an error. Lets assume we have three models which we must save to the server, and the `#save` method returns a promise. Reacting to these promises is easy to read, and avoids callback hell.

```ruby
Promise.when(model1.save, model2.save, model3.save).then do
  alert "Models were all saved"
end.fail do |err|
  alert "there was an error whilst saving: #{err}"
end
```
