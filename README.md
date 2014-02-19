HotelCompass
============

Search for Hotels nearby using [Booking.com][0] API.

##Disclaimer

I've coded this in a few days just to play a while with Booking.com API, this code is not intended to be released as a final product so there might be lot of bugs in there, and stuff that should be refactored.

##First Run

This project uses [CocoaPods][1] for dependency management. You'll have to download the dependencies first before getting started, otherwise you won't be able to compile. 

    $ pod install && open HotelCompass.xcworkspace

It's important after initial setup to always open `HotelCompass.xcworkspace` file from Xcode for development, since the workspace it's already configured to compile the `Pods` along the Project.

##Configuration

As Booking.com API is currently private and authenticated, you'll have to figure out how to get the credentials to have access to it. These are not distributed along the code since it might result on the violation on some of their policies, but they should be placed on `Settings.h` file.

License
=======

    The MIT License (MIT)
    
    Copyright (c) 2014 Diego Acosta
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    
[0]: http://www.booking.com/
[1]: http://cocoapods.org/
