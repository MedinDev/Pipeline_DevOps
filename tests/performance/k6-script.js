import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  thresholds: {
    http_req_duration: ["p(95)<500"],
    http_req_failed: ["rate<0.01"]
  }
};

const targetUrl = __ENV.TARGET_URL || "http://localhost:3000/healthz/ready";

export default function () {
  const response = http.get(targetUrl);
  check(response, {
    "status is 200": (r) => r.status === 200
  });
  sleep(1);
}
