module Actions
  module Katello
    module Host
      class HypervisorsUpdate < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(hypervisors)
          plan_self(:hypervisors => hypervisors)
        end

        def run
          output[:results] = input[:results]
        end

        def finalize
          hypervisors = input[:hypervisors]

          if hypervisors
            hypervisors.each { |hypervisor| update_or_create_hypervisor(hypervisor) }
          end
        end

        def update_or_create_hypervisor(hypervisor_json)
          organization = ::Organization.find_by(:label => hypervisor_json[:organization_label])

          # Since host names must be unique yet hypervisors may have unique subscription
          # facets in different orgs
          sanitized_name = ::Katello::Host::SubscriptionFacet.sanitize_name(hypervisor_json[:name])
          duplicate_name = "virt-who-#{sanitized_name}-#{organization.id}"
          host = ::Katello::Host::SubscriptionFacet.find_by(:uuid => hypervisor_json[:uuid]).try(:host)
          host ||= ::Host.find_by(:name => duplicate_name)
          if host && host.organization.try(:id) != organization.id
            fail _("Host '%{name}' does not belong to an organization") % {:name => host.name} unless host.organization
            host = nil
          end

          host ||= create_host_for_hypervisor(duplicate_name, organization)
          host.subscription_facet ||= ::Katello::Host::SubscriptionFacet.new
          host.subscription_facet.host_id = host.id
          host.subscription_facet.update_from_consumer_attributes(hypervisor_json)
          host.subscription_facet.uuid = hypervisor_json[:uuid]
          host.subscription_facet.save!
          host.save!
        end

        def create_host_for_hypervisor(name, organization, location = nil)
          location ||= Location.default_location
          host = ::Host::Managed.new(:name => name, :organization => organization,
                                     :location => location, :managed => false)
          host.save!
          host
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
