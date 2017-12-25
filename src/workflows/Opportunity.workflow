<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Delivery_Set_Name</fullName>
        <description>Sets the Name field on a Delivery</description>
        <field>Name</field>
        <formula>&apos;Delivery to &apos; + Account.Name + &apos; on &apos; +
TEXT(YEAR(CloseDate)) + &apos;-&apos; +
TEXT(MONTH(CloseDate)) + &apos;-&apos; +
TEXT(DAY(CloseDate))</formula>
        <name>Delivery: Set Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Stage_Delivered</fullName>
        <field>StageName</field>
        <literalValue>Delivered</literalValue>
        <name>Set Stage Delivered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Stage_In_Progress</fullName>
        <field>StageName</field>
        <literalValue>In Progress</literalValue>
        <name>Set Stage In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Stage_Verified</fullName>
        <field>StageName</field>
        <literalValue>Verified</literalValue>
        <name>Set Stage Verified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Delivery%3A Set Name</fullName>
        <actions>
            <name>Delivery_Set_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sets the Name on a delivery.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
