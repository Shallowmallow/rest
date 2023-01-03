package rest;

import http.HttpError;

class RestError {
    public var httpError:HttpError;

    public function new(httpError:HttpError = null, message:String = null) {
        this.httpError = httpError;
        if (message != null) {
            this.message = message;
        }
    }

    public var httpStatus(get, null):Null<Int>;
    private function get_httpStatus():Null<Int> {
        if (httpError == null) {
            return null;
        }
        return httpError.httpStatus;
    }

    private var _message:String;
    public var message(get, set):String;
    private function get_message():String {
        if (_message != null) {
            return _message;
        }
        if (httpError == null) {
            return null;
        }
        return httpError.message;
    }
    private function set_message(value:String):String {
        _message = value;
        return value;
    }

    public var bodyAsString(get, null):String;
    private function get_bodyAsString():String {
        if (httpError == null) {
            return null;
        }

        return httpError.bodyAsString;
    }

    public var bodyAsJson(get, null):Dynamic;
    private function get_bodyAsJson():Dynamic {
        if (httpError == null) {
            return null;
        }

        return httpError.bodyAsJson;
    }
}