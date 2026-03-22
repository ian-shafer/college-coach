import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;
using TypeSpec.Rest;

@service(#{
  title: "Echo API"
})
namespace EchoApp;

model EchoMessage {
  message: string;
}

@route("/echo")
@post
op echo(@body body: EchoMessage): EchoMessage;
