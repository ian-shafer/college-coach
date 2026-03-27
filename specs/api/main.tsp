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
  firstName?: string;
  lastName?: string;
  displayName?: string;
}

model AuthResponse {
  token: string;
}

model ErrorResponseBody {
  messages?: string[];
  errors?: Record<string>;
}

@error
model BadRequestResponse {
  @statusCode statusCode: 400;
  ...ErrorResponseBody;
}

@error
model InternalServerErrorResponse {
  @statusCode statusCode: 500;
  ...ErrorResponseBody;
}

@error
model UnauthorizedResponse {
  @statusCode statusCode: 401;
  ...ErrorResponseBody;
}

@error
model ConflictResponse {
  @statusCode statusCode: 409;
  ...ErrorResponseBody;
}

@route("/auth/register")
@post
op register(@body body: AuthRequest): AuthResponse | BadRequestResponse | ConflictResponse | InternalServerErrorResponse;

@route("/auth/login")
@post
op login(@body body: AuthRequest): AuthResponse | BadRequestResponse | UnauthorizedResponse;

@route("/auth/logout")
@post
op logout(): void;
