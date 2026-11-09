package no.pgr301.exam.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;

import java.util.UUID;

@Service
public class S3Service {

    private final S3Client s3;
    private final String bucket;
    private final Timer timer;

    public S3Service(S3Client s3, @Value("${app.s3.bucket}") String bucket, MeterRegistry registry) {
        this.s3 = s3;
        this.bucket = bucket;
        this.timer = Timer.builder("s3.upload.duration")
                .description("Time spent uploading the image to S3")
                .register(registry);
    }

    public String upload(byte[] bytes, String originalName, String contentType) {
        String key = "uploads/" + UUID.randomUUID() + "-" + (originalName == null ? "image" : originalName);
        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .contentType(contentType == null ? "application/octet-stream" : contentType)
                .build();
        timer.record(() -> s3.putObject(request, RequestBody.fromBytes(bytes)));
        return key;
    }
}
