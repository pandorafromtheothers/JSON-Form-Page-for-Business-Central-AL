You want to test an interface in Business Central, but you always have to Publish your app, because of changing variables?
You can get around this issue with this JSON-Form type AL Page.

Create a JSON Object with a scheme like this:

![image](https://github.com/pandorafromtheothers/JSON-Form-Page-for-Business-Central-AL/assets/115832798/34dda0a7-0338-4a72-9712-d243010d5d15)

Pass that JSON to the form-opening procedure:

![image](https://github.com/pandorafromtheothers/JSON-Form-Page-for-Business-Central-AL/assets/115832798/bab29ce5-1f46-4383-9742-707d40e096db)

And upon using it you should have results like these:

![readme](https://github.com/pandorafromtheothers/JSON-Form-Page-for-Business-Central-AL/assets/115832798/ec65a95a-3716-4d56-a902-e941899eb533)
![readme2](https://github.com/pandorafromtheothers/JSON-Form-Page-for-Business-Central-AL/assets/115832798/b7fa5ba2-43b6-4c38-8fc4-2a2df80bfb76)
![readme3](https://github.com/pandorafromtheothers/JSON-Form-Page-for-Business-Central-AL/assets/115832798/a0b9e3c2-363c-4107-8443-3c6b0e1c8145)
![readme4](https://github.com/pandorafromtheothers/JSON-Form-Page-for-Business-Central-AL/assets/115832798/53106d5a-c2cb-4e31-bbec-a2fc7edd7c4e)

You can also use it to just receive singular values from the form.

Check out the Test Page to get familiar with it.

Have Fun!
