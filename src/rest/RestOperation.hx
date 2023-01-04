package rest;

import haxe.io.Bytes;
import http.StandardHeaders;
import haxe.Json;
import http.ContentTypes;
import haxe.http.HttpMethod;
import http.HttpMethod;
import promises.Promise;
import haxe.Constraints.Constructible;

using StringTools;

@:generic
@:access(rest.IMappable)
@:access(rest.IParsable)
@:access(rest.IParsableError)
class RestOperation<TRequest:IMappable,
                    TResponse:Constructible<Void->Void> & IParsable,
                    TError:Constructible<Void->Void> & IParsableError> {
    public var verb:HttpMethod = HttpMethod.Get;
    public var path:String;
    public var queryParams:Map<String, Any>;
    public var bodyType:BodyType = BodyType.None;
    public var client:RestClient;
    public var useAlternateConfig:Bool = false;

    public function new() {
    }

    public function call(request:TRequest = null):Promise<TResponse> {
        return new Promise((resolve, reject) -> {
            var restRequest = new RestRequest();
            var requestParamMap = null;
            if (request != null) {
                requestParamMap = request.toMap();
            }
            restRequest.urlParams = requestParamMap;
            restRequest.queryParams = queryParams;
            restRequest.verb = verb;
            restRequest.path = path;
            restRequest.useAlternateConfig = this.useAlternateConfig;

            if (bodyType != BodyType.None) {
                switch (bodyType) {
                    case BodyType.Json:
                        restRequest.body = request.toObject();
                        if (restRequest.headers == null) {
                            restRequest.headers = [StandardHeaders.ContentType => ContentTypes.ApplicationJson];
                        } else if (!restRequest.headers.exists(StandardHeaders.ContentType)) {
                            restRequest.headers.set(StandardHeaders.ContentType, ContentTypes.ApplicationJson);
                        }
                    case _:    
                }
            }

            client.makeRequest(restRequest).then(restResult -> {
                var response = new TResponse();
                var contentType = restResult.response.contentType;
                var responseBody:Any = restResult.response.bodyAsString;
                /* dont think we want to auto parse response bodies, this is what the response parsers are for
                if (contentType != null) {
                    if (contentType.startsWith(ContentTypes.ApplicationJson)) {
                        //responseBody = Json.parse(restResult.response.bodyAsString);
                    }
                }
                */

                try {
                    response.parse(responseBody);
                } catch (e:Dynamic) {
                    var restError = new RestError();
                    restError.body = Bytes.ofString(Std.string(e));
                    var error = new TError();
                    error.parse(restError);
                    reject(error);
                }
                resolve(response);
            }, (restError:RestError) -> {
                var error = new TError();
                error.parse(restError);
                reject(error);
            });
        });
    }
}