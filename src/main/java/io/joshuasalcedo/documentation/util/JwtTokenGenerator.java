package io.joshuasalcedo.documentation.util;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Date;
import java.util.UUID;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import org.springframework.stereotype.Component;

/**
 * Simple JWT token generator for API authentication
 * Note: This is a simplified implementation for demonstration purposes
 */
@Component
public class JwtTokenGenerator {

    private static final String SECRET_KEY = System.getenv("JWT_SECRET") != null ? 
            System.getenv("JWT_SECRET") : "defaultSecretKeyForDocumentationAppShouldBeChanged";
    private static final long EXPIRATION_TIME = 86400000; // 24 hours in milliseconds
    
    /**
     * Generates a JWT token
     * @param username User identifier
     * @return Generated JWT token
     */
    public String generateToken(String username) {
        try {
            // Create JWT header
            String header = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
            String encodedHeader = base64UrlEncode(header);
            
            // Create JWT payload
            long now = System.currentTimeMillis();
            String payload = String.format(
                    "{\"sub\":\"%s\",\"iat\":%d,\"exp\":%d,\"jti\":\"%s\"}",
                    username, 
                    now / 1000, 
                    (now + EXPIRATION_TIME) / 1000, 
                    UUID.randomUUID().toString()
            );
            String encodedPayload = base64UrlEncode(payload);
            
            // Create signature
            String signature = hmacSha256(encodedHeader + "." + encodedPayload, SECRET_KEY);
            
            // Combine to form JWT
            return encodedHeader + "." + encodedPayload + "." + signature;
            
        } catch (Exception e) {
            throw new RuntimeException("Error generating JWT token", e);
        }
    }
    
    private String base64UrlEncode(String str) {
        return Base64.getUrlEncoder().withoutPadding()
                .encodeToString(str.getBytes(StandardCharsets.UTF_8));
    }
    
    private String hmacSha256(String data, String secret) 
            throws NoSuchAlgorithmException, InvalidKeyException {
        
        SecretKeySpec secretKey = new SecretKeySpec(
                secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(secretKey);
        byte[] hmacData = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        return Base64.getUrlEncoder().withoutPadding().encodeToString(hmacData);
    }
}
