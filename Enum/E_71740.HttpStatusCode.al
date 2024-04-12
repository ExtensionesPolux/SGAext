enum 71740 HttpStatusCode
{
    Extensible = true;

    value(100; Continue)
    {
        Caption = 'Equivalente al código de estado HTTP 100. Continue indica que el cliente puede continuar con su solicitud.';
    }
    value(101; SwitchingProtocols)
    {
        Caption = 'Equivalente al código de estado HTTP 101. SwitchingProtocols indica que se está modificando la versión de protocolo o el protocolo.';
    }
    value(102; Processing)
    {
        Caption = 'Equivalente al código de estado HTTP 102. Processing indica que el servidor ha aceptado la solicitud completa pero todavía no la ha completado.';
    }
    value(103; EarlyHints)
    {
        Caption = 'Equivalente al código de estado HTTP 103. EarlyHints indica al cliente que es probable que el servidor envíe una respuesta final con los campos de encabezado incluidos en la respuesta informativa.';
    }
    value(200; OK)
    {
        Caption = 'Equivalente al código de estado HTTP 200. OK indica que la solicitud se realizó correctamente y la información solicitada se incluye en la respuesta. Este es el código de estado más habitual que se va a recibir.';
    }
    value(201; Created)
    {
        Caption = 'Equivalente al código de estado HTTP 201. Created indica que la solicitud dio como resultado un nuevo recurso creado antes de enviar la respuesta.';
    }
    value(202; Accepted)
    {
        Caption = 'Equivalente al código de estado HTTP 202. Accepted indica que se aceptó la solicitud para su posterior procesamiento.';
    }
    value(203; NonAuthoritativeInformation)
    {
        Caption = 'Equivalente al código de estado HTTP 203. NonAuthoritativeInformation indica que la meta información devuelta procede de una copia almacenada en caché en lugar del servidor de origen y por lo tanto puede ser incorrecta.';
    }
    value(204; NoContent)
    {
        Caption = 'Equivalente al código de estado HTTP 204. NoContent indica que la solicitud se procesó correctamente y la respuesta está intencionadamente en blanco.';
    }
    value(205; ResetContent)
    {
        Caption = 'Equivalente al código de estado HTTP 205. ResetContent indica que el cliente debe restablecer (no recargar) el recurso actual.';
    }
    value(206; PartialContent)
    {
        Caption = 'Equivalente al código de estado HTTP 206. PartialContent indica que la respuesta es una respuesta parcial conforme a una solicitud GET que incluye un intervalo de bytes.';
    }
    value(207; MultiStatus)
    {
        Caption = 'Equivalente al código de estado HTTP 207. MultiStatus indica varios códigos de estado para una sola respuesta durante una operación del Sistema distribuido de creación y control de versiones web (WebDAV). El cuerpo de la respuesta contiene XML que describe los códigos de estado.';
    }
    value(208; AlreadyReported)
    {
        Caption = 'Equivalente al código de estado HTTP 208. AlreadyReported indica que los miembros de un enlace de WebDAV ya se han enumerado en una parte anterior de la respuesta multiestado y no se incluyen de nuevo.';
    }
    value(226; IMUsed)
    {
        Caption = 'Equivalente al código de estado HTTP 226. IMUsed indica que el servidor ha atendido una solicitud del recurso y la respuesta es una representación del resultado de una o varias manipulaciones de instancia aplicadas a la instancia actual.';
    }
    value(300; Ambiguous)
    {
        Caption = 'Equivalente al código de estado HTTP 300. Ambiguous indica que la información solicitada tiene varias representaciones. La acción predeterminada consiste en tratar este estado como una redirección y seguir el contenido del encabezado Location asociado a esta respuesta. Ambiguous es un sinónimo de MultipleChoices.';
    }
    value(301; Moved)
    {
        Caption = 'Equivalente al código de estado HTTP 301. Moved indica que la información solicitada se ha trasladado al URI especificado en el encabezado Location. La acción predeterminada cuando se recibe este estado es seguir el encabezado Location asociado a la respuesta. Si el método de solicitud original era POST la solicitud redirigida utilizará el método GET. Moved es un sinónimo de MovedPermanently.';
    }
    value(302; Found)
    {
        Caption = 'Equivalente al código de estado HTTP 302. Found indica que la información solicitada se encuentra en el URI especificado en el encabezado Location. La acción predeterminada cuando se recibe este estado es seguir el encabezado Location asociado a la respuesta. Si el método de solicitud original era POST la solicitud redirigida utilizará el método GET. Found es un sinónimo de Redirect.';
    }
    value(303; RedirectMethod)
    {
        Caption = 'Equivalente al código de estado HTTP 303. RedirectMethod redirige automáticamente el cliente al URI especificado en el encabezado Location como resultado de una acción POST. La solicitud al recurso especificado por el encabezado Location se realizará con GET. RedirectMethod es un sinónimo de SeeOther.';
    }
    value(304; NotModified)
    {
        Caption = 'Equivalente al código de estado HTTP 304. NotModified indica que está actualizada la copia en caché del cliente. No se transfiere el contenido del recurso.';
    }
    value(305; UseProxy)
    {
        Caption = 'Equivalente al código de estado HTTP 305. UseProxy indica que la solicitud debe utilizar el servidor proxy en el URI especificado en el encabezado Location.';
    }
    value(306; Unused)
    {
        Caption = 'Equivalente al código de estado HTTP 306. Unused es una extensión propuesta de la especificación HTTP/1.1 que no está totalmente especificada.';
    }
    value(307; RedirectKeepVerb)
    {
        Caption = 'Equivalente al código de estado HTTP 307. RedirectKeepVerb indica que la información de la solicitud se encuentra en el URI especificado en el encabezado Location. La acción predeterminada cuando se recibe este estado es seguir el encabezado Location asociado a la respuesta. Si el método de solicitud original era POST la solicitud redirigida también utilizará el método GET. RedirectKeepVerb es un sinónimo de TemporaryRedirect.';
    }
    value(308; PermanentRedirect)
    {
        Caption = 'Equivalente al código de estado HTTP 308. PermanentRedirect indica que la información de la solicitud se encuentra en el URI especificado en el encabezado Location. La acción predeterminada cuando se recibe este estado es seguir el encabezado Location asociado a la respuesta. Si el método de solicitud original era POST la solicitud redirigida también utilizará el método GET.';
    }
    value(400; BadRequest)
    {
        Caption = 'Equivalente al código de estado HTTP 400. BadRequest indica que el servidor no entendió la solicitud. Se envía BadRequest cuando ningún otro error es aplicable se desconoce el error exacto o este no tiene su propio código de error.';
    }
    value(401; Unauthorized)
    {
        Caption = 'Equivalente al código de estado HTTP 401. Unauthorized indica que el recurso solicitado requiere autenticación. El encabezado WWW-Authenticate contiene los detalles de cómo realizar la autenticación.';
    }
    value(402; PaymentRequired)
    {
        Caption = 'Equivalente al código de estado HTTP 402. PaymentRequired se reserva para un uso futuro.';
    }
    value(403; Forbidden)
    {
        Caption = 'Equivalente al código de estado HTTP 403. Forbidden indica que el servidor rechaza atender la solicitud.';
    }
    value(404; NotFound)
    {
        Caption = 'Equivalente al código de estado HTTP 404. NotFound indica que el recurso solicitado no existe en el servidor.';
    }
    value(405; MethodNotAllowed)
    {
        Caption = 'Equivalente al código de estado HTTP 405. MethodNotAllowed indica que no se permite el método de solicitud (POST o GET) en el recurso solicitado.';
    }
    value(406; NotAcceptable)
    {
        Caption = 'Equivalente al código de estado HTTP 406. NotAcceptable indica que el cliente ha señalado con encabezados Accept que ya no aceptará ninguna de las representaciones disponibles del recurso.';
    }
    value(407; ProxyAuthenticationRequired)
    {
        Caption = 'Equivalente al código de estado HTTP 407. ProxyAuthenticationRequired indica que el proxy solicitado requiere autenticación. El encabezado Proxy-authenticate contiene los detalles de cómo realizar la autenticación.';
    }
    value(408; RequestTimeout)
    {
        Caption = 'Equivalente al código de estado HTTP 408. RequestTimeout indica que el cliente no envió una solicitud en el intervalo de tiempo durante el cual el servidor la esperaba.';
    }
    value(409; Conflict)
    {
        Caption = 'Equivalente al código de estado HTTP 409. Conflict indica que no se pudo realizar la solicitud debido a un conflicto en el servidor.';
    }
    value(410; Gone)
    {
        Caption = 'Equivalente al código de estado HTTP 410. Gone indica que el recurso solicitado ya no está disponible.';
    }
    value(411; LengthRequired)
    {
        Caption = 'Equivalente al código de estado HTTP 411. LengthRequired indica que falta el encabezado Content-Length requerido.';
    }
    value(412; PreconditionFailed)
    {
        Caption = 'Equivalente al código de estado HTTP 412. PreconditionFailed indica un error relativo a una condición establecida para esta solicitud lo cual impide su realización. Las condiciones se establecen mediante encabezados de solicitud condicional como If-Match If-None-Match o If-Unmodified-Since.';
    }
    value(413; RequestEntityTooLarge)
    {
        Caption = 'Equivalente al código de estado HTTP 413. RequestEntityTooLarge indica que la solicitud es demasiado grande para que el servidor la pueda procesar.';
    }
    value(414; RequestUriTooLong)
    {
        Caption = 'Equivalente al código de estado HTTP 414. RequestUriTooLong indica que el URI es demasiado largo.';
    }
    value(415; UnsupportedMediaType)
    {
        Caption = 'Equivalente al código de estado HTTP 415. UnsupportedMediaType indica que el tipo de la solicitud no es compatible.';
    }
    value(416; RequestedRangeNotSatisfiable)
    {
        Caption = 'Equivalente al código de estado HTTP 416. RequestedRangeNotSatisfiable indica que no se puede devolver el intervalo de datos solicitado desde el recurso porque el comienzo del intervalo se encuentra delante del comienzo del recurso o porque el final del intervalo se encuentra detrás del final del recurso.';
    }
    value(417; ExpectationFailed)
    {
        Caption = 'Equivalente al código de estado HTTP 417. ExpectationFailed indica que el servidor no pudo cumplir la expectativa dada en un encabezado Expect.';
    }
    value(421; MisdirectedRequest)
    {
        Caption = 'Equivalente al código de estado HTTP 421. MisdirectedRequest indica que la solicitud se dirigió en un servidor que no puede generar una respuesta.';
    }
    value(422; UnprocessableContent)
    {
        Caption = 'Equivalente al código de estado HTTP 422. UnprocessableContent indica que la solicitud tenía el formato correcto pero no pudo seguirse debido a errores semánticos. UnprocessableContent es un sinónimo de UnprocessableEntity.';
    }
    value(423; Locked)
    {
        Caption = 'Equivalente al código de estado HTTP 423. Locked indica que el recurso de origen o de destino está bloqueado.';
    }
    value(424; FailedDependency)
    {
        Caption = 'Equivalente al código de estado HTTP 424. FailedDependency indica que el método no se pudo realizar en el recurso porque la acción solicitada dependía de otra acción y se produjo un error en la acción.';
    }
    value(426; UpgradeRequired)
    {
        Caption = 'Equivalente al código de estado HTTP 426. UpgradeRequired indica que el cliente debería cambiar a otro protocolo como TLS/1.0.';
    }
    value(428; PreconditionRequired)
    {
        Caption = 'Equivalente al código de estado HTTP 428. PreconditionRequired indica que el servidor requiere que la solicitud sea condicional.';
    }
    value(429; TooManyRequests)
    {
        Caption = 'Equivalente al código de estado HTTP 429. TooManyRequests indica que el usuario ha enviado demasiadas solicitudes en un período de tiempo determinado.';
    }
    value(431; RequestHeaderFieldsTooLarge)
    {
        Caption = 'Equivalente al código de estado HTTP 431. RequestHeaderFieldsTooLarge indica que es difícil que el servidor procese la solicitud porque sus campos de encabezado (ya sea un campo de encabezado individual o todos los campos de encabezado colectivamente) son demasiado grandes.';
    }
    value(451; UnavailableForLegalReasons)
    {
        Caption = 'Equivalente al código de estado HTTP 451. UnavailableForLegalReasons indica que el servidor está denegando el acceso al recurso como consecuencia de una demanda legal.';
    }
    value(500; InternalServerError)
    {
        Caption = 'Equivalente al código de estado HTTP 500. InternalServerError indica que se produjo un error genérico en el servidor.';
    }
    value(501; NotImplemented)
    {
        Caption = 'Equivalente al código de estado HTTP 501. NotImplemented indica que el servidor no admite la función solicitada.';
    }
    value(502; BadGateway)
    {
        Caption = 'Equivalente al código de estado HTTP 502. BadGateway indica que un servidor proxy intermedio recibió una respuesta errónea de otro proxy o del servidor de origen.';
    }
    value(503; ServiceUnavailable)
    {
        Caption = 'Equivalente al código de estado HTTP 503. ServiceUnavailable indica que el servidor está temporalmente no disponible normalmente por motivos de sobrecarga o mantenimiento.';
    }
    value(504; GatewayTimeout)
    {
        Caption = 'Equivalente al código de estado HTTP 504. GatewayTimeout indica que un servidor proxy intermedio agotó su tiempo de espera mientras aguardaba una respuesta de otro proxy o del servidor de origen.';
    }
    value(505; HttpVersionNotSupported)
    {
        Caption = 'Equivalente al código de estado HTTP 505. HttpVersionNotSupported indica que el servidor no admite la versión HTTP solicitada.';
    }
    value(506; VariantAlsoNegotiates)
    {
        Caption = 'Equivalente al código de estado HTTP 506. VariantAlsoNegotiates indica que el recurso de variante elegido está configurado para participar en una negociación de contenido transparente y por tanto no es un punto de conexión adecuado en el proceso de negociación.';
    }
    value(507; InsufficientStorage)
    {
        Caption = 'Equivalente al código de estado HTTP 507. InsufficientStorage indica que el servidor no puede almacenar la representación necesaria para completar la solicitud.';
    }
    value(508; LoopDetected)
    {
        Caption = 'Equivalente al código de estado HTTP 508. LoopDetected indica que el servidor ha finalizado una operación porque encontró un bucle infinito al procesar una solicitud de WebDAV con Profundidad: Infinito. Este código de estado se ha diseñado a efectos de compatibilidad con versiones anteriores de los clientes que no reconocen el código de estado 208 AlreadyReported que aparece en los cuerpos de respuesta multiestado.';
    }
    value(510; NotExtended)
    {
        Caption = 'Equivalente al código de estado HTTP 510. NotExtended indica que se necesitan más extensiones de la solicitud para que el servidor la atienda.';
    }
    value(511; NetworkAuthenticationRequired)
    {
        Caption = 'Equivalente al código de estado HTTP 511. NetworkAuthenticationRequired indica que el cliente debe autenticarse para obtener acceso a la red; está diseñado para su uso mediante la interceptación de servidores proxy que se usan para controlar el acceso a la red.';
    }
}