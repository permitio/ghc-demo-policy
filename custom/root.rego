package permit.custom

import future.keywords.in
import data.permit.policies
import data.permit.utils.abac
import data.permit.rebac
import data.permit.debug

default allow := false

# Ignore the date check if there is no ReBac
allow {
	not "rebac" in policies.__allow_sources
	print("No ReBac")
} else {
	count(filter_resource) == 0
	print("No filtered resource")
} else {
	print("Filtered resource")
	some filtered_resource in filter_resource
	debug.custom.filtered = filtered_resource
	enforce_boundries(filtered_resource)
}

filter_resource[derived_resource] {
	print("Derived resource")
	some allowing_role in rebac.rebac_roles_debugger
	print("Allowing role: ", allowing_role.role)
	some source in allowing_role.sources
	print("Source: ", source)
	print("Source type: ", source.type
	print("Source role: ", source.role)
	print("Source resource: ", source.resource)
	endswith(source.role, "#caregiver")
	derived_resource := exctract_resouce(source, allowing_role.role, allowing_role.resource)
	print("Derived resource: ", derived_resource)
}

exctract_resouce(source, role, resource) := returned_resource {
	source.type == "role_assignment"
	returned_resource := resource
} else {
	source.type == "role_derivation"
	returned_resource := source.resource
}

enforce_boundries(resource) {
	time.parse_rfc3339_ns(abac.attributes.user.caregiver_bounds[resource].start_date) >= time.now_ns()
	time.parse_rfc3339_ns(abac.attributes.user.caregiver_bounds[resource].end_date) <= time.now_ns()
}
