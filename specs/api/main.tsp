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
  firstName?: string;
  lastName?: string;
  displayName?: string;
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

@error
model BadRequestResponse {
  @statusCode statusCode: 400;
  message: string;
}

@error
model InternalServerErrorResponse {
  @statusCode statusCode: 500;
  message: string;
}

@error
model UnauthorizedResponse {
  @statusCode statusCode: 401;
  message: string;
}

@error
model ConflictResponse {
  @statusCode statusCode: 409;
  message: string;
}

@route("/auth/register")
@post
op register(@body body: AuthRequest): AuthResponse | BadRequestResponse | ConflictResponse | InternalServerErrorResponse;

@route("/auth/login")
@post
op login(@body body: AuthRequest): AuthResponse | BadRequestResponse | UnauthorizedResponse;
