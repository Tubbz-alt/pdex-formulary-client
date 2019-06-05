################################################################################
#
# Drug Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class FormularyDrug < Resource

  include ActiveModel::Model

	attr_accessor :drug_name, :drug_tier, :drug_class, :rxnorm_code, :id, 
									:prior_auth, :step_therapy, :quantity_limit, :errors, 
									:warnings

	#-----------------------------------------------------------------------------

	def initialize(fhir_formulary)
		@id  							= parse_id(fhir_formulary)
		@drug_name				= parse_drug_name(fhir_formulary)
		@rxnorm_code 			= parse_rxnorm_code(fhir_formulary)
		#@drug_class				= parse_drug_class(fhir_formulary)

		parse_extensions(fhir_formulary)
	end
	
	#-----------------------------------------------------------------------------
	private
	#-----------------------------------------------------------------------------

	# Isolates the ID from the formulary drug resource.

	def parse_id(fhir_formulary)
		return fhir_formulary.id
	end

	#-----------------------------------------------------------------------------

	# Isolates the drug name from the formulary drug resource.  If the drug name
	# is missing, it posts an error message since it is a required element.

	def parse_drug_name(fhir_formulary)
		if (code = fhir_formulary.code).present?
			if (coding = code.coding).present?
				value = display_list(coding)
			else
				value = "code.coding not specified"
			end
		else
			value = "Drug name not specified"
		end

		return value
	end

	#-----------------------------------------------------------------------------

	# Isolates the RxNorm code from the formulary drug resource.  If the RxNorm
	# code is missing, it posts an error message since it is a required element.

	def parse_rxnorm_code(fhir_formulary)
		if (code = fhir_formulary.code).present?
			if (coding = code.coding).present?
				value = code_list(coding)
			else
				value = "code.coding not specified" 
			end
		else
			value = "RxNorm code not specified"
		end

		return value
	end

 	#-----------------------------------------------------------------------------

 	# Parses the values within the extensions defined by the formulary drug 
 	# resource.

	def parse_extensions(fhir_formulary)
		extensions = fhir_formulary.extension
		if extensions.present?
			extensions.each do |extension|
				if extension.url.include?("DrugTierID")
					@drug_tier = parse_drug_tier(extension)
				elsif extension.url.include?("PriorAuthorization")
					@prior_auth = extension.valueBoolean
				elsif extension.url.include?("StepTherapyLimit")
					@step_therapy = extension.valueBoolean
				elsif extension.url.include?("QuantityLimit")
					@quantity_limit = extension.valueBoolean
				end
			end
		else
			@drug_tier = "Required extensions not specified"
		end
	end

	#-----------------------------------------------------------------------------

	def parse_drug_tier(extension)
		if (concept = extension.valueCodeableConcept).present?
			if (coding = concept.coding).present?
				value = display_list(coding)
			else
				value = "Drug tier not specified"
			end
		else
			value = "Codeable concept not present"
		end

		return value
	end

	#-----------------------------------------------------------------------------

	def display_list(list)
		list.map{ |element| element.display }.join(', ')
	end

	#-----------------------------------------------------------------------------

	# Concatenates a list of code elements.

	def code_list(list)
		list.map{ |element| element.code }.join(', ')
	end

end