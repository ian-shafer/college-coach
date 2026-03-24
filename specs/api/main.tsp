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
op echo(@body body: EchoMessage): EchoMessage | BadRequestResponse;

model User {
  id: string;
  email: string;
  fullName: string;
  displayName: string;
  @doc("ISO-8601 formatted UTC datetime")
  createdAt: utcDateTime;
  @doc("ISO-8601 formatted UTC datetime")
  updatedAt: utcDateTime;
}

model AuthRequest {
  email: string;
  password: string;
}

model AuthResponse {
  token: string;
}

@route("/auth/register")
@post
op register(@body body: AuthRequest): AuthResponse | BadRequestResponse;

@route("/auth/login")
@post
op login(@body body: AuthRequest): AuthResponse | BadRequestResponse;
