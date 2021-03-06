import ceylon.io.buffer {
    ByteBuffer
}
import ceylon.net.http.server.websocket {
    FragmentedBinarySender,
    WebSocketChannel
}

import io.undertow.websockets.core {
    WebSockets {
        wsSendBinary=sendBinary,
        wsSendBinaryBlocking=sendBinaryBlocking,
        wsSendClose=sendClose,
        wsSendCloseBlocking=sendCloseBlocking
    },
    WebSocketFrameType
}
import ceylon.io.charset {
    utf8
}
import java.nio {
    JByteBuffer=ByteBuffer
}
import ceylon.language.meta.model {
    IncompatibleTypeException
}

by("Matej Lazar")
class DefaultFragmentedBinarySender(DefaultWebSocketChannel channel)
        satisfies FragmentedBinarySender {

    value fragmentedChannel = channel.underlyingChannel.send(WebSocketFrameType.\iBINARY);

    shared actual void sendBinary(ByteBuffer binary, Boolean finalFrame) {
        value wsChannel = fragmentedChannel.webSocketChannel;

        Object? jByteBuffer = binary.implementation;
        if (is JByteBuffer jByteBuffer) {
            if (finalFrame) {
                wsSendCloseBlocking(jByteBuffer , wsChannel);
            } else {
                wsSendBinaryBlocking(jByteBuffer, wsChannel);
            }
        } else {
            throw IncompatibleTypeException("Inalid underlying implementation, Java ByteBuffer was expected.");
        }
    }
    
    shared actual void sendBinaryAsynchronous(
            ByteBuffer binary,
            Anything(WebSocketChannel) onCompletion,
            Anything(WebSocketChannel,Exception)? onError,
            Boolean finalFrame) {

        value wsChannel = fragmentedChannel.webSocketChannel;

        Object? jByteBuffer = binary.implementation;
        if (is JByteBuffer jByteBuffer) {
            if (finalFrame) {
                wsSendClose(jByteBuffer , wsChannel, wrapCallbackSend(onCompletion, onError, channel));
            } else {
                wsSendBinary(jByteBuffer, wsChannel, wrapCallbackSend(onCompletion, onError, channel));
            }
        } else {
            throw IncompatibleTypeException("Inalid underlying implementation, Java ByteBuffer was expected.");
        }
    }
}
