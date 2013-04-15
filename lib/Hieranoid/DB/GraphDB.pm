#
#===============================================================================
#
#         FILE: GraphDB.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Fabian Schreiber (), fs9@sanger.ac.uk
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 04/12/2013 08:53:34
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use REST::Neo4p;



sub lookup_index(){
 	my %args = @_;
    my $search_term = $args{search_term};	
	
	REST::Neo4p->connect('http://127.0.0.1:7474');
	my $idx = REST::Neo4p->get_index_by_name('cluster_root',$search_term);
	print Dumper $idx;
	
	return defined($idx) ? $idx : undef;
	 
}

sub get_cluster2genes_mappings(){
 	my %args = @_;
    my $search_term = $args{search_term};	
	my $og_assignments_hashref = $args{og_assignments_hashref};
	REST::Neo4p->connect('http://127.0.0.1:7474');
	my $query = REST::Neo4p::Query->new(
				  'START n=node(*) 
					MATCH n-[r]->m 
					RETURN m.name as cluster_root, n.name as member;'
  					);
	$query->execute;
	while (my $result = $query->fetch) {
    	my ($cluster_root, $member) = ($result->[0]->get_property('name'),$result->[1]->get_property('name') );
		$og_assignments_hashref->{$cluster_root} .= $member.","; 
   		print "$cluster_root ",'->', "$member\n";
	}
	print "\n we found ".keys(%{$og_assignments_hashref})." cluster roots\n";
}
1;
