## Notes 
- All documentation is contained within the [docs](docs/) folder (SLOs and architecture diagram).
- The [docker-compose](docker-compose.yml) was updated to include a proxy for HTTPS as well as to include prometheus and grafana for monitoring enhancements.
- The required [nginx config](nginx.conf) is located at the base of the directory while self-signed certs are located in the [certs](certs/) directory.
- To be a bit fancy and prevent errors if Grafana wasn't fully booted up and available by the time nginx was configured, I'm using a resolver to Docker's internal DNS and setting grafana's address to a variable. This makes Nginx skip the startup check so it only tries to find the IP once the first request comes in. I'm also making the nginx service depend on grafana, which likely could have fixed it as well, but why not do both.

### Date 
March 23, 2026

### Location of deployed application 
Not available, must be ran locally via `docker compose up`

### Time spent 
5 hours

### Assumptions made 
- The document sent mentions a Rails application but I was linked to this project, which is a python application. I'm assuming this was a simple mistype and carried on as such.
- Assumed the KV will be a smaller part of a larger whole, influencing some architectural decisions.

### Shortcuts/Compromises made 
Tying back to the assumption made, since I don't have the full context I made an assumption about the KV being a smaller part of a larger whole and so that lead my design choices. With the ability to ask some more clarifying questions regarding intention, cost expectations, what other applications that may already be running this may depend on or will use this, etc. I would cater my design to all those criteria. 

### Stretch goals attempted 
- Since my original design was already open to multi-tenancy, it wasn't much extra effort to elaborate on how I'd expand this to be multi-tenancy.
- Included a roll-out plan for the basic single-tenancy model, not considering any multi-tenancy or external dependencies.

### Instructions to run assignment locally 
Simply run `docker compose up --build` and then visit https://localhost in your browser. 

### What did you not include in your solution that you want us to know about? 
There are nuances regarding Route53/DNS/routing I didn't get in to for a multi-tenancy strategy. Thing such as subdomains vs. pathed routing, an ingress gateway vs. an ALB per application.

### Other information about your submission that you feel it's important that we know if applicable.
### Your feedback on this technical challenge 
I actually went in to the repo and started working off the README before realizing there was an attached document with entirely different instructions. It might be good to make it a bit more clear in the email that the provided git repo should be used but not the README in it.
