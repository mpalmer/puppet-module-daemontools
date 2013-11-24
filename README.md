Installs, configures, and manages
[daemontools](http://cr.yp.to/daemontools.html) services.

Note: This module does *not* use Puppet's "daemontools" provider for the "service"
type, as that conflates a service being enabled with one being running.

The main type you're probably interested in is `daemontools::service`, which
sets up a service to run under the guiding hand of daemontools.  It does all
sorts of fancy shenanigans, too.  If you're out to spawn a whole pile of
eerily similar services (say parallel job queue workers), you might want to
take a gander at the `daemontools::servicegroup` type.

# Noop resources

The following Noop resources are available for use by other Puppet modules:

* `Noop["daemontools/service:${service}"]`

    Defined if the Daemontools service $service is defined. It may be notified
    to cause the service to be restarted.
