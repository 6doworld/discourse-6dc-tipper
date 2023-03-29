export default function () {
  this.route(
    "siwe-auth",
    { path: "/discourse-6dc-tipper/auth" },
    function () {
      this.route("index", { path: "/" });
    }
  );
}
